<style lang="stylus">
  .empty
    text-align center
    padding-top 3em
    padding-bottom 3em
  .controls
    display flex
    justify-content space-between
  .value
    color gray
    max-height 10em
    overflow-y auto
  .url
    width 100%
    white-space nowrap
    overflow hidden
    text-overflow ellipsis
</style>

<template lang="pug">
  #items
    h1.empty(v-if="items.length == 0") Nothing here yet. Go track something!
    sui-segment(v-for="item in items" :key="item.id")
      h2 {{item.settings.nickname}}
      p.url
        a(href="#" @click="openUrl(item.url)") {{item.url}}
      sui-grid(:columns="2" relaxed="very")
        sui-grid-column
          h4 Current
          p.value {{item.history[0].value}}
        sui-grid-column
          h4 Previous
          p.value {{item.history[1].value}}
      sui-segment.controls
        button.ui.basic.tiny.button(@click="pause(item)") {{ item.settings.paused? "Resume" : "Pause" }}
        router-link.ui.basic.tiny.button(:to="{path: `/item/${item.id}/settings`}") Settings
        router-link.ui.basic.tiny.button(:to="{path: `/item/${item.id}/history`}") History
        button.ui.basic.tiny.button.red(@click="remove(item)") Delete
</template>

<script lang="coffee">
  export default
    computed:
      items: -> this.$store.getters.items
    methods:
      pause: (item) ->
        chrome.runtime.sendMessage
          type: "setItemPaused"
          id: item.id
          paused: !item.settings.paused
      remove: (item) ->
        this.$store.dispatch('deleteItem', item.id)
      openUrl: (url) ->
        chrome.tabs.create({"url": url})
</script>
