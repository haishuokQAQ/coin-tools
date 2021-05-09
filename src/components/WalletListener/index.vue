<template>
  <div />
</template>

<script>
import { syncConnectStatus } from '@/api/web3.js'

export default {
  name: 'WalletListener',
  created() {
    // 连接钱包
    syncConnectStatus(this)
    // 添加listener
    window.ethereum.on('networkChanged', function(params) {
      console.log(params)
      console.log(window.ethereum.selectedAddress)
    })
    window.ethereum.on('accountsChanged', function(params) {
      console.log(params)
    })
  },
  methods: {
    validateNet(args) {
      console.log('net ', args)
    },
    validateAccount(args) {
      console.log('account', args)
    }
  }
}
</script>

<style scoped>

</style>
