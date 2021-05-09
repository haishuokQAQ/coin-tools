
const state = {
  connected: false,
  address: '',
  web3: null
}

const mutations = {
  SET_ETH: (connected, address) => {
    state.connected = connected
    state.address = address
  }
}

const actions = {
}

export default {
  namespaced: true,
  state,
  mutations,
  actions
}
