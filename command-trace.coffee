_         = require 'lodash'
colors    = require 'colors'
moment    = require 'moment'
commander = require 'commander'
tab = require 'tab'
Elasticsearch = require 'elasticsearch'
debug     = require('debug')('command-trace:check')
QUERY = require './get-logs-by-deployment-uuid.json'

class CommandTrace
  parseOptions: =>
    commander
      .usage '<deploymentUuid>'
      .parse process.argv

    @deploymentUuid = _.first commander.args
    @ELASTICSEARCH_URL = process.env.ELASTICSEARCH_URL ? 'http://localhost:9201'
    @elasticsearch = new Elasticsearch.Client host: @ELASTICSEARCH_URL

  run: =>
    @parseOptions()
    return @die new Error('Missing deploymentUuid') unless @deploymentUuid?

    @trace()

  trace: =>
    @search (error, results) =>
      return @die error if error?
      logs = results.hits.hits.reverse()
      @printTable _.map logs, (log) =>
        {application,state} = log._source.payload
        timestamp = moment(log.fields._timestamp).format()
        [timestamp, application, state]
      process.exit 0

  printTable: (rows) =>
    tab.emitTable
      columns: [
        {label: 'TIME', width: 28},
        {label: 'APPLICATION', width: 22}
        {label: 'STATE', width: 10}
      ]
      rows: rows

  search: (callback=->) =>
    @elasticsearch.search({
      index: 'device_status_flow'
      type:  'event'
      body:  QUERY
    }, callback)

  die: (error) =>
    if 'Error' == typeof error
      console.error colors.red error.message
    else
      console.error colors.red arguments...
    process.exit 1

new CommandTrace().run()
