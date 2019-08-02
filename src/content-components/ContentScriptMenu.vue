<template lang="pug">
  sui-modal#WebsiteTrackerProModal(v-model="$root.open")
    sui-modal-header Website Tracker Pro
    sui-modal-content
      sui-modal-description
        .ui.error.message(v-if="errors.length")
          .header Oops...
          ul.list
            li(v-for="error in errors") {{error}}
        sui-form
          sui-form-field
            label Value
            code {{ $root.value }}
          sui-form-field
            label What do you want to call this?
            input(v-model="$root.nickname")
          sui-form-field
            label Selector (only change this if you know what you're doing!)
            input(v-model="$root.selector")
          sui-form-fields
            sui-form-field
              label Check this item every
              input(v-model.number="interval")
            sui-form-field
              label . . .
              sui-dropdown(:options="timeUnits" placeholder="Time Unit" selection v-model="timeUnit")

    sui-modal-actions
      sui-button(@click="cancel") Cancel
      sui-button(@click="save" positive) Track it!
</template>

<script lang="coffee">
  export default
    data: ->
      errors: []
      timeUnits:
        [
          {value: 1000,     text: "Seconds"}
          {value: 60000,    text: "Minutes"}
          {value: 3600000,  text: "Hours"}
          {value: 86400000, text: "Days"}
        ]
      timeUnit: 60000
      interval: 5
    methods:
      cancel: ->
        this.$root.open = false;
      save: ->
        this.errors = []

        if typeof this.interval isnt 'number'
          this.errors.push "Interval must be a number"
        else if this.interval <= 0
          this.errors.push "Interval must be greater than zero"

        if !this.$root.nickname
          this.errors.push "Nickname can't be blank"

        unless this.errors.length
          now = Date.now()
          item =
            id: this.$uuid.v1()
            url: window.location.href
            nextCheck: now + this.interval * this.timeUnit
            settings:
              paused: false
              desktopNotifications: true
              emailNotifications: false
              emailNotificationRecipients: ""
              nickname: this.$root.nickname
              selector: this.$root.selector
              interval: this.interval
              timeUnit: this.timeUnit
            history:
              [
                {timestamp: now, value: this.$root.value}
                {timestamp: null, value: null}
              ]
          chrome.runtime.sendMessage({type: 'saveItem', item: item}, =>
            this.$root.open = false)
</script>
