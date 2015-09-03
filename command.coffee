commander   = require 'commander'
packageJSON = require './package.json'

class Command
  run: =>
    commander
      .version packageJSON.version
      .command 'list-failures', 'get list of gateblu-deployment failures in last 24 hours'
      .command 'trace',         'trace a gateblu deployment'
      .command 'gateblu-activity', 'show activity for a gateblu uuid'
      .parse process.argv

    unless commander.runningCommand
      commander.outputHelp()
      process.exit 1

(new Command()).run()
