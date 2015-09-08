_         = require 'lodash'
colors    = require 'colors'
moment    = require 'moment'
commander = require 'commander'
tab = require 'tab'
Elasticsearch = require 'elasticsearch'
debug     = require('debug')('command-trace:check')
QUERY = require './get-logs-by-gateblu-uuid.json'

class CommandTrace
  parseOptions: =>
    commander
      .usage '<gateblu-uuid>'
      .option '-o, --omit-header', 'Omit meta-information and table header'
      .parse process.argv

    @gatebluUuid = _.first commander.args
    @ELASTICSEARCH_URL = process.env.ELASTICSEARCH_URL ? 'http://localhost:9201'
    @elasticsearch = new Elasticsearch.Client host: @ELASTICSEARCH_URL

    @omitHeader = commander.omitHeader ? false

  run: =>
    @parseOptions()
    return @die new Error('Missing gateblu UUID') unless @gatebluUuid?

    @trace()

  trace: =>
    @search (error, results) =>
      return @die error if error?
      logs = results.hits.hits.reverse()

      @printTable _.map logs, (log) =>
        {workflow,application,state,deploymentUuid,message,connector,gatebluVersion,platform} = log._source.payload
        timestamp = moment(log.fields._timestamp).format()
        connector = connector.replace(/^meshblu-/, '')
        application = application.replace(/^gateblu-/, '')
        readableVersion = "(v#{gatebluVersion})" if gatebluVersion?
        readablePlatform = "[#{platform}]" if platform?
        application += "#{readableVersion ? ""}#{readablePlatform ? ""}"
        message ?= ""
        [timestamp, workflow, application, state, connector, deploymentUuid, message]

      process.exit 0

  printTable: (rows) =>
    tab.emitTable
      omitHeader: @omitHeader
      columns: [
        {label: 'TIME', width: 26},
        {label: 'WORKFLOW', width: 20},
        {label: 'APPLICATION', width: 25}
        {label: 'STATE', width: 10}
        {label: 'CONNECTOR', width: 10}
        {label: 'DEPLOYMENT_UUID', width: 38}
        {label: 'MESSAGE', width: 40}
      ]
      rows: rows

  search: (callback=->) =>
    @elasticsearch.search({
      index: 'device_status_gateblu'
      type:  'event'
      body:  @query()
    }, callback)

  query: =>
    query = _.cloneDeep QUERY
    query.query.filtered.filter.term['payload.gatebluUuid.raw'] = @gatebluUuid
    query

  die: (error) =>
    if 'Error' == typeof error
      console.error colors.red error.message
    else
      console.error colors.red arguments...
    process.exit 1

new CommandTrace().run()
