_         = require 'lodash'
colors    = require 'colors'
moment    = require 'moment'
commander = require 'commander'
tab = require 'tab'
Elasticsearch = require 'elasticsearch'
debug     = require('debug')('command-trace:check')
QUERY = require './get-activity.json'

class CommandTrace
  parseOptions: =>
    commander
      .option '-o, --omit-header', 'Omit meta-information and table header'
      .parse process.argv

    @ELASTICSEARCH_URL = process.env.ELASTICSEARCH_URL ? 'http://localhost:9201'
    @elasticsearch = new Elasticsearch.Client host: @ELASTICSEARCH_URL

    @omitHeader = commander.omitHeader ? false

  run: =>
    @parseOptions()
    @listFailures()

  listFailures: =>
    @search (error, results) =>
      return @die error if error?
      logs = results.hits.hits.reverse()

      @printTable _.map logs, (log) =>
        {workflow,state,message,deploymentUuid,connector,application,gatebluVersion,platform} = log._source.payload
        timestamp = moment(log.fields._timestamp).format()
        connector = connector?.replace(/^meshblu-/, '')
        application = application?.replace(/^gateblu-/, '')
        readableVersion = "(v#{gatebluVersion})" if gatebluVersion?
        readablePlatform = "[#{platform}]" if platform?
        application += "#{readableVersion ? ""}#{readablePlatform ? ""}"
        message ?= ''
        connector ?= 'unknown'
        application ?= 'unknown'
        workflow ?= 'unknown'
        state ?= 'unknown'
        deploymentUuid ?= 'unknown'
        [timestamp, workflow, application, state, connector, deploymentUuid, message]

      process.exit 0

  printTable: (rows) =>
    tab.emitTable
      omitHeader: @omitHeader
      columns: [
        {label: 'TIME', width: 28},
        {label: 'WORKFLOW', width: 20}
        {label: 'APPLICATION', width: 25}
        {label: 'STATE', width: 10}
        {label: 'CONNECTOR', width: 13}
        {label: 'DEPLOYMENT_UUID', width: 38}
        {label: 'MESSAGE', width: 38}
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
    two_days_ago = moment().subtract(2,'day').valueOf()
    query.query.filtered.filter = range: _timestamp: gte: two_days_ago
    query

  die: (error) =>
    if 'Error' == typeof error
      console.error colors.red error.message
    else
      console.error colors.red arguments...
    process.exit 1

new CommandTrace().run()
