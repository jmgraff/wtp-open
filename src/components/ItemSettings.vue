<style lang="stylus">
  #settings
    padding-bottom 1em
  .hint
    font-size x-small
    font-style italic
    text-align right
</style>

<template lang="pug">
  #settings.ui.container
    h1 {{item.settings.nickname}} Settings
    .ui.error.message(v-if="errors.length")
      .header Oops...
      ul
        li(v-for="error in errors") {{error}}
    sui-form(v-on:submit.prevent)
      sui-form-field
        label Nickname
        input(v-model="item.settings.nickname")
      sui-form-field
        label Selector
        input(v-model="item.settings.selector")
      p.hint Only change this if you know what you're doing!
      sui-form-fields
        sui-form-field
          label Check this every
          input(v-model.number="item.settings.interval")
        sui-form-field
          label . . .
          sui-dropdown(:options="timeUnits" placeholder="Time Unit" selection v-model="item.settings.timeUnit")
      p.hint Next check will be {{new Date(Date.now() + item.settings.interval * item.settings.timeUnit).toLocaleString()}}
      sui-form-field
        sui-checkbox(label="Enable desktop notifications" v-model="item.settings.desktopNotifications")
      sui-form-field
        sui-checkbox(label="Enable Gmail notifications" v-model="item.settings.emailNotifications" @click="loadDefaultEmail")
      sui-form-field(v-if="item.settings.emailNotifications")
        label Recipients (separate with ";")
        input(v-model="item.settings.emailNotificationRecipients")
      .form-controls
        button.ui.basic.tiny.blue.button(@click="save" type="button") Save
        router-link.ui.basic.tiny.button(to="/") Cancel
</template>

<script lang="coffee">
  export default
    data: ->
      errors: []
      userEmail: ""
      item: JSON.parse(JSON.stringify(this.$store.getters.item(this.$route.params.id)))
      timeUnits:
        [
          {value: 1000,     text: "Seconds"}
          {value: 60000,    text: "Minutes"}
          {value: 3600000,  text: "Hours"}
          {value: 86400000, text: "Days"}
        ]
    methods:
      save: ->
        this.errors = []

        if typeof this.item.settings.interval isnt 'number'
          this.errors.push "Interval must be a number"
        else if this.item.settings.interval <= 0
          this.errors.push "Interval must be greater than zero"

        if !this.item.settings.nickname
          this.errors.push "Nickname can't be blank"

        if this.item.settings.emailNotifications and !this.item.settings.emailNotificationRecipients
          this.errors.push "Must have at least one email recipient"

        unless this.errors.length
          this.item.nextCheck = Date.now() + this.item.settings.interval * this.item.settings.timeUnit
          this.$store.dispatch("saveItemSettings", this.item)
          this.$router.push "/"

      loadDefaultEmail: ->
        if this.item.settings.emailNotifications and !this.item.settings.emailNotificationRecipients
          chrome.identity.getProfileUserInfo (userInfo) =>
            this.item.settings.emailNotificationRecipients = userInfo.email + "; "
</script>
