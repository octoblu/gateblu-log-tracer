_         = require 'lodash'
colors    = require 'colors'
moment    = require 'moment'
commander = require 'commander'
tab = require 'tab'
Elasticsearch = require 'elasticsearch'
debug     = require('debug')('command-trace:check')
QUERY = require './get-failed-deployments.json'

class CommandTrace
  parseOptions: =>
    commander
      .option '-o, --omit-header', 'Omit meta-information and table header'
      .parse process.argv

    @ELASTICSEARCH_URL = process.env.ELASTICSEARCH_URL ? 'http://searchonly:q1c5j3slso793flgu0@0b0a9ec76284a09f16e189d7017ad116.us-east-1.aws.found.io:9200'
    @elasticsearch = new Elasticsearch.Client host: @ELASTICSEARCH_URL

    @omitHeader = commander.omitHeader ? false

  run: =>
    @parseOptions()
    @listFailures()

  listFailures: =>
    @search (error, results) =>
      return @die error if error?
      logs = results.hits.hits

      @printTable _.map logs, (log) =>
        {beginTime, workflow, deploymentUuid} = log._source
        timestamp = moment(beginTime).format()
        [timestamp, workflow, deploymentUuid]

      process.exit 0

  printTable: (rows) =>
    tab.emitTable
      omitHeader: @omitHeader
      columns: [
        {label: 'TIME', width: 28},
        {label: 'WORKFLOW', width: 10}
        {label: 'DEPLOYMENT_UUID', width: 34}
      ]
      rows: rows

  search: (callback=->) =>
    @elasticsearch.search({
      index: 'gateblu_device_add_history'
      type:  'event'
      body:  @query()
    }, callback)

  query: =>
    query = _.cloneDeep QUERY
    one_day_ago = moment().subtract(1,'day').valueOf()
    query.query.filtered.filter.and.push range: beginTime: gte: one_day_ago
    query

  die: (error) =>
    if 'Error' == typeof error
      console.error colors.red error.message
    else
      console.error colors.red arguments...
    process.exit 1

new CommandTrace().run()
