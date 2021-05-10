<template>
  <div id="deply" style="height: 100%">
    <el-card style="margin-left: 5px">
      <el-form label-width="auto" label-position="left">
        <el-form-item label="代币名称">
          <el-input id="tokenName" v-model="tokenName" placeholder="请输入代币名称" />
        </el-form-item>
        <el-form-item label="代币简称">
          <el-input id="symbol" v-model="symbol" placeholder="请输入代币简称" />
        </el-form-item>
        <el-form-item label="代币数量">
          <el-input id="amount" v-model="amount" placeholder="请输入代币数量" />
        </el-form-item>
        <el-form-item label="小数位数(1-18位)">
          <el-input-number v-model="num" :min="1" :max="18" label="小数位数（1-18）" />
        </el-form-item>
        <el-form-item>
          <el-checkbox-group v-model="checkList">
            <el-checkbox label="可销毁" />
            <el-checkbox label="可增发" />
            <el-checkbox label="可暂停" />
            <el-checkbox label="黑名单" />
            <el-checkbox label="通货紧缩" />
          </el-checkbox-group>
        </el-form-item>
      </el-form>
      <div style="text-align:right;">
        <el-button type="primary" @click="deploy">确定</el-button>
        <el-button type="primary" @click="printForm">查看表单</el-button>
      </div>
    </el-card>
  </div>
</template>
<script>
var account
window.addEventListener('load', async() => {
  if (window.ethereum) {
    // eslint-disable-next-line no-undef
    window.web3 = new Web3(ethereum)
    try {
      // eslint-disable-next-line no-undef
      await ethereum.enable()
      // eslint-disable-next-line no-undef
      account = web3.eth.accounts[0]
      localStorage.setItem('address', account)
      // eslint-disable-next-line no-undef
      console.log('当前默认网络为：' + web3.version.network)
    } catch (error) {
      console.log('User denied account access...')
    }
  } else if (window.web3) {
    // eslint-disable-next-line no-undef
    window.web3 = new Web3(web3.currentProvider)
    // eslint-disable-next-line no-undef
    account = web3.eth.accounts[0]
    localStorage.setItem('address', account)
    console.log('web3:' + account)
    // eslint-disable-next-line no-undef
    console.log('当前默认网络为：' + web3.version.network)
  } else {
    console.log('Non-Ethereum browser detected. You should consider trying MetaMask!')
  }
  // eslint-disable-next-line no-undef
  ethereum.on('networkChanged', function(networkIDstring) {
    console.log('切换了网络，当前是：' + networkIDstring)
  })
})

export default {
  data() {
    return {
      tokenName: '',
      amount: 1000000000,
      symbol: '',
      num: 18,
      checkList: []
    }
  },
  methods: {
    printForm: function() {
      console.log(this._data)
    },
    deploy: function() {
      var tokenName = this.tokenName
      var symbol = this.symbol
      var amount = this.amount
      var adr = localStorage.getItem('address')
      var bytecode = '60806040526002805460ff1916601217905534801561001d57600080fd5b50604051610a04380380610a0483398101604090815281516020808401518385015160025460ff16600a0a84026003819055336000908152600485529586205590850180519395909491019261007592850190610092565b508051610089906001906020840190610092565b5050505061012d565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106100d357805160ff1916838001178555610100565b82800160010185558215610100579182015b828111156101005782518255916020019190600101906100e5565b5061010c929150610110565b5090565b61012a91905b8082111561010c5760008155600101610116565b90565b6108c88061013c6000396000f3006080604052600436106100b95763ffffffff7c010000000000000000000000000000000000000000000000000000000060003504166306fdde0381146100be578063095ea7b31461014857806318160ddd1461018057806323b872dd146101a7578063313ce567146101d157806342966c68146101fc57806370a082311461021457806379cc67901461023557806395d89b4114610259578063a9059cbb1461026e578063cae9ca5114610292578063dd62ed3e146102fb575b600080fd5b3480156100ca57600080fd5b506100d3610322565b6040805160208082528351818301528351919283929083019185019080838360005b8381101561010d5781810151838201526020016100f5565b50505050905090810190601f16801561013a5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34801561015457600080fd5b5061016c600160a060020a03600435166024356103b0565b604080519115158252519081900360200190f35b34801561018c57600080fd5b50610195610416565b60408051918252519081900360200190f35b3480156101b357600080fd5b5061016c600160a060020a036004358116906024351660443561041c565b3480156101dd57600080fd5b506101e661048b565b6040805160ff9092168252519081900360200190f35b34801561020857600080fd5b5061016c600435610494565b34801561022057600080fd5b50610195600160a060020a036004351661050c565b34801561024157600080fd5b5061016c600160a060020a036004351660243561051e565b34801561026557600080fd5b506100d36105ef565b34801561027a57600080fd5b5061016c600160a060020a0360043516602435610649565b34801561029e57600080fd5b50604080516020600460443581810135601f810184900484028501840190955284845261016c948235600160a060020a031694602480359536959460649492019190819084018382808284375094975061065f9650505050505050565b34801561030757600080fd5b50610195600160a060020a0360043581169060243516610778565b6000805460408051602060026001851615610100026000190190941693909304601f810184900484028201840190925281815292918301828280156103a85780601f1061037d576101008083540402835291602001916103a8565b820191906000526020600020905b81548152906001019060200180831161038b57829003601f168201915b505050505081565b336000818152600560209081526040808320600160a060020a038716808552908352818420869055815186815291519394909390927f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925928290030190a350600192915050565b60035481565b600160a060020a038316600090815260056020908152604080832033845290915281205482111561044c57600080fd5b600160a060020a0384166000908152600560209081526040808320338452909152902080548390039055610481848484610795565b5060019392505050565b60025460ff1681565b336000908152600460205260408120548211156104b057600080fd5b3360008181526004602090815260409182902080548690039055600380548690039055815185815291517fcc16f5dbb4873280815c1ee09dbd06736cffcc184412cf7a71a0fdb75d397ca59281900390910190a2506001919050565b60046020526000908152604090205481565b600160a060020a03821660009081526004602052604081205482111561054357600080fd5b600160a060020a038316600090815260056020908152604080832033845290915290205482111561057357600080fd5b600160a060020a0383166000818152600460209081526040808320805487900390556005825280832033845282529182902080548690039055600380548690039055815185815291517fcc16f5dbb4873280815c1ee09dbd06736cffcc184412cf7a71a0fdb75d397ca59281900390910190a250600192915050565b60018054604080516020600284861615610100026000190190941693909304601f810184900484028201840190925281815292918301828280156103a85780601f1061037d576101008083540402835291602001916103a8565b6000610656338484610795565b50600192915050565b60008361066c81856103b0565b15610770576040517f8f4ffcb10000000000000000000000000000000000000000000000000000000081523360048201818152602483018790523060448401819052608060648501908152875160848601528751600160a060020a03871695638f4ffcb195948b94938b939192909160a490910190602085019080838360005b838110156107045781810151838201526020016106ec565b50505050905090810190601f1680156107315780820380516001836020036101000a031916815260200191505b5095505050505050600060405180830381600087803b15801561075357600080fd5b505af1158015610767573d6000803e3d6000fd5b50505050600191505b509392505050565b600560209081526000928352604080842090915290825290205481565b6000600160a060020a03831615156107ac57600080fd5b600160a060020a0384166000908152600460205260409020548211156107d157600080fd5b600160a060020a038316600090815260046020526040902054828101116107f757600080fd5b50600160a060020a038083166000818152600460209081526040808320805495891680855282852080548981039091559486905281548801909155815187815291519390950194927fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef929181900390910190a3600160a060020a0380841660009081526004602052604080822054928716825290205401811461089657fe5b505050505600a165627a7a72305820da7b1bcbe13ffe39233f338d72b2e3f63f40a52d8df95038b3e41d397940ee6a0029'
      var jsonApi = '[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_value","type":"uint256"}],"name":"burn","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_value","type":"uint256"}],"name":"burnFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"},{"name":"_extraData","type":"bytes"}],"name":"approveAndCall","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[{"name":"initialSupply","type":"uint256"},{"name":"tokenName","type":"string"},{"name":"tokenSymbol","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Burn","type":"event"}]'
      // eslint-disable-next-line no-undef
      var MyContract = web3.eth.contract(JSON.parse(jsonApi))
      // eslint-disable-next-line no-undef,no-unused-vars
      var gasPrice = 10000000000
      // eslint-disable-next-line no-undef
      web3.eth.getGasPrice(function(err, res) {
        if (!err) {
          console.log(res.toString(10))
          gasPrice = res.toString(10)
        } else {
          console.log(err)
        }
      })
      MyContract.new(amount, tokenName, symbol, {
        data: bytecode,
        from: adr.toString(),
        gas: 3000000,
        gasPrice: gasPrice
      }, function(err, res) {
        if (!err) {
          console.log(res)
        } else {
          console.log(err)
        }
      })
    }
  }
}
</script>
<style>
</style>
