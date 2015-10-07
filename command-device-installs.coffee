_             = require 'lodash'
colors        = require 'colors'
moment        = require 'moment'
commander     = require 'commander'
tab           = require 'tab'
Elasticsearch = require 'elasticsearch'
debug         = require('debug')('command-trace:check')
QUERY         = require './get-logs-by-device.json'

class CommandTrace
  parseOptions: =>
    commander
      .usage ''
      .parse process.argv

    @ELASTICSEARCH_URL = process.env.ELASTICSEARCH_URL ? 'http://localhost:9201'
    @elasticsearch = new Elasticsearch.Client host: @ELASTICSEARCH_URL

  run: =>
    @parseOptions()
    @process()

  process: =>
    @search (error, results) =>
      return @die error if error?
      logs = []
      connectorBuckets = results.aggregations.addGatebluDevice.group_by_connector.buckets
      _.each connectorBuckets, (connectorBucket) =>
        logs.push [connectorBucket.key, connectorBucket.doc_count]
      _.sortBy logs, (record) =>
        return record[2]
      @printTable logs

      process.exit 0

  printTable: (rows) =>
    tab.emitTable
      omitHeader: false
      columns: [
        {label: 'CONNECTOR', width: 35}
        {label: 'COUNT', width: 20}
      ]
      rows: rows

  search: (callback=->) =>
    @elasticsearch.search({
      index: 'device_status_gateblu'
      type:  'event'
      search_type: 'count'
      body:  @query()
    }, callback)

  query: =>
    query = _.cloneDeep QUERY
    return query

  die: (error) =>
    if 'Error' == typeof error
      console.error colors.red error.message
    else
      console.error colors.red arguments...
    process.exit 1

new CommandTrace().run()
