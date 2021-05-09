import Web3 from 'web3';

export async function connectWallet(vueObj) {
  if (window.ethereum) {
    const result = await window.ethereum.enable()
    console.log(result)
    const obj = new Web3(window.ethereum)
    const accounts = await obj.eth.getAccounts()
    vueObj.$store.state.eth.web3 = obj
    vueObj.$store.state.eth.account = accounts[0]
    vueObj.$store.state.eth.connected = true
  } else {
    alert('未监测到钱包')
  }
}

export function clearConnectStatus(vueObj) {
  vueObj.$store.state.eth.connected = false
  vueObj.$store.state.eth.web3 = null
  vueObj.$store.state.eth.address = ''
}

export function syncConnectStatus(vueObj) {
  if (window.ethereum) {
    const connected = window.ethereum.selectedAddress !== null
    vueObj.$store.state.eth.connected = connected
    if (connected) {
      if (!vueObj.$store.state.eth.web3) {
        vueObj.$store.state.eth.web3 = new Web3(window.ethereum)
      }
      vueObj.$store.state.eth.address = window.ethereum.selectedAddress
    } else {
      console.log('未连接')
    }
  } else {
    alert('未检测到钱包')
    return false
  }
}

