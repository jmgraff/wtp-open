<template lang="pug">
  #history.ui.container
    h1 {{item.settings.nickname}} History
    .form-controls
      button.ui.basic.tiny.green.button(@click="exportToCSV") Export to CSV
      router-link.ui.basic.tiny.button(to="/") Cancel
    sui-table(celled unstackable)
      sui-table-header
        sui-table-row
          sui-table-headerCell Time
          sui-table-headerCell Value
      sui-table-body
        sui-table-row(v-for="(entry, index) in item.history.slice(0,item.history.length-1)" :key="index")
          sui-table-cell {{formatTime(entry.timestamp)}}
          sui-table-cell {{entry.value}}
</template>

<script lang="coffee">

  export default
    data: ->
      item: JSON.parse(JSON.stringify(this.$store.getters.item(this.$route.params.id)))
    methods:
      formatTime: (t) -> new Date(t).toLocaleString()
      exportToCSV: ->
        slugify = require('slugify')
        CSVBuilder = require('csv-builder')
        csvContent = "data:text/csv;charset=utf-8,"
        builder = new CSVBuilder({headers: ['Time', 'Value']})
          .virtual 'Time', (row) -> new Date(row.timestamp).toLocaleString()
          .virtual 'Value', (row) -> row.value
        csvContent += builder.getHeaders()
        csvContent += builder.getRow(row) for row in this.item.history when row.value isnt null
        encodedURI = encodeURI(csvContent)
        link = document.createElement 'a'
        link.setAttribute 'href', encodedURI
        link.setAttribute 'download', "#{slugify(this.item.settings.nickname)}-history.csv"
        link.click()
      save: ->
        this.$router.push "/"
</script>
