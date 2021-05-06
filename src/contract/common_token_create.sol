pragma solidity ^0.4.0;

contract common_token_create {
  string public name; // ERC20标准
  string public symbol; // ERC20标准
  uint8 public decimals = 2;  // ERC20标准，decimals 可以有的小数点个数，最小的代币单位。18 是建议的默认值
  uint256 public totalSupply; // ERC20标准 总供应量
  // 用mapping保存每个地址对应的余额 ERC20标准
  mapping(address => uint256) public balanceOf;
  // 存储对账号的控制 ERC20标准
  mapping(address => mapping(address => uint256)) public allowance;

  bool stopped;


  // TODO 需要验证以下问题：1.构造函数中抛出异常会怎样，是否可以在构造时校验参数？ 2. require的结果是怎么传出的？
  function common_token_create(string tokenName, string tokenSymbol, uint8 decimals,
    uint256 initialSupply, bool _increasing, bool _burnable, bool _stoppable, bool _useBlackList,
    int _commissionRatio, int _transferBurnRatio, address _commissionRecvAddr, address _owner){
    // 供应的份额，份额跟最小的代币单位有关，份额 = 币数 * 10 ** decimals。
    totalSupply = initialSupply * 10 ** uint256(decimals);
    // 创建者拥有所有的代币
    balanceOf[_owner] = totalSupply;
    // 代币名称
    name = tokenName;
    // 代币符号
    symbol = tokenSymbol;
    // 是否能够增发
    increasing = _increasing;
    // 是否支持销毁
    burnable = _burnable;
    // 是否支持暂停
    stoppable = _stoppable;
    // 是否使用黑名单
    useBlackList = _useBlackList;
    // 交易手续费比例
    commissionRatio = _commissionRatio;
    // 交易手续费收取地址
    commissionRecvAddr = _commissionRecvAddr;
    // 交易销毁比例
    burnRatio = _transferBurnRatio;
    // 设置token的owner
    owner = _owner;
    // 初始化默认为放开交易状态
    stopped = false;
  }

  // 可增发
  bool public increasing;
  // 可销毁
  bool public burnable;
  // 可暂停
  bool public stoppable;
  // 支持黑名单
  bool public useBlackList;
  address[] public blackList;
  // 通缩
  int public commissionRatio;
  int public burnRatio;
  address public commissionRecvAddr;

  // 记录token的拥有者
  address private owner;

  // ERC20的基础方法实现
  // 事件，用来通知客户端交易发生 ERC20标准
  event Transfer(address indexed from, address indexed to, uint256 value);

  event Burn(address indexed from, uint256 value);

  event Increase(address indexed from, uint256 value);

  /**
     * 代币交易转移的内部实现
     */
  function _transfer(address _from, address _to, uint _value) internal {
    // 确保目标地址不为0x0，因为0x0地址代表销毁
    require(_to != 0x0);

    // 检查发送者余额
    require(balanceOf[_from] >= _value);
    // 确保转移为正数个
    require(balanceOf[_to] + _value > balanceOf[_to]);
    // 添加通缩逻辑stub
    commissionFee = _getCommissionFee(_value);
    burnFee = _getBurnFee(_value);
    actualTransferValue = _value - commissionFee - burnFee;
    // 以下用来检查交易，
    uint previousBalances = balanceOf[_from] + balanceOf[_to];
    // Subtract from the sender
    balanceOf[_from] -= actualTransferValue;
    // Add the same to the recipient
    balanceOf[_to] += actualTransferValue;
    _doCommission(commissionFee);
    _doBurn(burnFee);
    Transfer(_from, _to, _value);

    // 用assert来检查代码逻辑。
    assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
  }

  /**
   *  代币交易转移
   *  从自己（创建交易者）账号发送`_value`个代币到 `_to`账号
   * ERC20标准
   * @param _to 接收者地址
   * @param _value 转移数额
   */
  function transfer(address _to, uint256 _value) public {
    require(!stopped);
    require(!inBlackList());
    _transfer(msg.sender, _to, _value);
  }

  /**
   * 账号之间代币交易转移
   * ERC20标准
   * @param _from 发送者地址
   * @param _to 接收者地址
   * @param _value 转移数额
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(!stopped);
    require(!inBlackList());
    require(_value <= allowance[_from][msg.sender]);
    // Check allowance
    allowance[_from][msg.sender] -= _value;
    _transfer(_from, _to, _value);
    return true;
  }

  /**
   * 设置某个地址（合约）可以创建交易者名义花费的代币数。
   *
   * 允许发送者`_spender` 花费不多于 `_value` 个代币
   * ERC20标准
   * @param _spender The address authorized to spend
   * @param _value the max amount they can spend
   */
  function approve(address _spender, uint256 _value) public
  returns (bool success) {
    require(!stopped);
    allowance[msg.sender][_spender] = _value;
    return true;
  }


  // 实现增发,增发的货币会添加到货币owner的地址中
  function increase(uint256 _count) public
  returns (bool success){
    require(!stopped);
    // 开关校验
    require(increasing);
    require(!inBlackList());
    // 非token的owner不允许增发
    require(msg.sender != owner);
    balanceOf[msg.sender] += _count;
    totalSupply += _count;
    Increase(msg.sender, _count);
    return true;
  }

  // 实现销毁
  /**
   * 销毁我（创建交易者）账户中指定个代币
   *-非ERC20标准
   */
  function burn(uint256 _value) public returns (bool success) {
    require(!stopped);
    require(burnable);
    require(!inBlackList());
    return _doBurn(_value);
  }

  function _doBurn(uint256 _countToBurn) public returns (bool success) {
    require(balanceOf[msg.sender] >= _countToBurn);
    // Check if the sender has enough
    balanceOf[msg.sender] -= _countToBurn;
    // Subtract from the sender
    totalSupply -= _countToBurn;
    // Updates totalSupply
    Burn(msg.sender, _countToBurn);
    return true;
  }

  // 实现暂停
  function stop() public {
    require(stoppable);
    require(msg.sender == owner);
    stopped = true;
  }

  function start() public {
    require(stoppable);
    require(msg.sender == owner);
    stopped = false;
  }

  function addInBlackList(address addr) {
    require(msg.sender == owner);
    require(_inBlackList(addr));
    blackList.push(addr);
  }

  // 黑名单
  function inBlackList() public
  returns (bool in) {
    callerAddr = msg.sender;
    return _inBlackList(callerAddr);
  }

  function _inBlackList(address addr)
  returns (bool in) {
    for (uint i = 0; i < blackList.length; i++) {
      if (addr == blackList[i]) {
        return true;
      }
    }
    return false;
  }

  // 通缩相关
  // 收取手续费
  function _doCommission(int _commissionValue) {
    if (commissionRecvAddr == null) {
      return;
    }
    if (_commissionValue == 0) {
      return;
    }
    _transfer(msg.sender, commissionRecvAddr, _commissionValue);
  }

  function _doDestroyWhenTransfer(int _burnValue) {
    if (burnRatio == 0) {
      return;
    }
    _doBurn(_burnValue);
  }

  function _getCommissionFee(uint256 _transferValue)
  returns (uint256 commissionFee) {
    return _transferValue * commissionRatio / 100;
  }

  function _getBurnFee(uint256 _transferValue)
  returns (uint256 burnFee) {
    return _transferValue * burnRatio / 100;
  }
}
