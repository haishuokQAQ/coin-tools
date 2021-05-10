<template>
  <div id="app">
    <WalletListener />
    <router-view />
  </div>
</template>

<script>
import WalletListener from '@/components/WalletListener'

export default {
  name: 'App',
  components: {
    WalletListener
  }
}
</script>
