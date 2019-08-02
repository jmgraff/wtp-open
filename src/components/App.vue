<style lang="stylus">
  #layout
    width 450px

  header
    display flex
    justify-content center
    border-bottom 1px dotted gray
    padding 1em

  main
    height 30em
    overflow-x hidden
    overflow-y auto

  footer
    display flex
    justify-content center
    border-top 1px dotted gray
    padding 1em

  .form-controls
    display flex
    justify-content flex-end

</style>

<template lang="pug">
  #layout
    header
      h1 Website Tracker Pro
    main
      router-view
    footer
      button.massive.blue.ui.button(@click="foo") Track something on this page!
</template>



<script lang="coffee">
  import VueRouter from 'vue-router'

  import ItemList from './ItemList.vue'
  import ItemSettings from './ItemSettings.vue'
  import ItemHistory from './ItemHistory.vue'

  routes = [
    { path: '/', component: ItemList }
    { path: '/item/:id/settings', component: ItemSettings }
    { path: '/item/:id/history', component: ItemHistory }
  ]

  export default {
    router: new VueRouter { routes }
    components: { ItemList, ItemSettings, ItemHistory }
    methods:
      foo: -> chrome.runtime.sendMessage({type: 'inject'}, -> window.close())
  }
</script>
