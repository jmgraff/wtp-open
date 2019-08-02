import 'semantic-ui-css/semantic.min.css'

import Vue from 'vue'
import Vuex from 'vuex'
import VueRouter from 'vue-router'
import SuiVue from 'semantic-ui-vue'


import App from './components/App.vue'

Vue.use plugin for plugin in [Vuex, VueRouter, SuiVue]

store = new Vuex.Store
  state:
    items: []
  getters:
    items: (state) -> state.items
    item: (state) ->
      (id) ->
        (state.items.filter (i) -> i.id is id)[0]
  mutations:
    SET_ITEMS: (state,  items) ->
      state.items = items
  actions:
    getItems: ({commit}) ->
      chrome.runtime.sendMessage({type: "getItems"},
        (r) -> commit('SET_ITEMS', r.items))
    deleteItem: ({dispatch}, id) ->
      chrome.runtime.sendMessage({type: "deleteItem", id: id},
        (r) -> dispatch 'getItems')
    saveItemSettings: ({dispatch}, item) ->
      chrome.runtime.sendMessage({type: "saveItemSettings", item: item},
        (r) -> dispatch 'getItems')

new Vue {
  el: '#app'
  store
  render: (h) -> h App
  mounted: -> this.$store.dispatch 'getItems'
}

chrome.runtime.onMessage.addListener (request,sender,respond) ->
  switch request.type
    when "setItems"
      store.commit("SET_ITEMS", request.items)
      return
