commander   = require 'commander'
packageJSON = require './package.json'

class Command
  run: =>
    commander
      .version packageJSON.version
      .command 'list-failures', 'get list of flow-deployment failures in last 24 hours'
      .command 'trace', 'trace a flow deployment'
      .parse process.argv

    unless commander.runningCommand
      commander.outputHelp()
      process.exit 1

(new Command()).run()
