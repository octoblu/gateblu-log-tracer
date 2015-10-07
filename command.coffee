commander   = require 'commander'
packageJSON = require './package.json'

class Command
  run: =>
    commander
      .version packageJSON.version
      .command 'list-activity',    'get list of gateblu activity in last 24 hours'
      .command 'list-failures',    'get list of gateblu-deployment failures in last 24 hours'
      .command 'group-failures',   'get list of gateblu failed activity grouped by gateblu in last 24 hours'
      .command 'trace',            'trace a gateblu deployment'
      .command 'gateblu-activity', 'show activity for a gateblu uuid'
      .command 'device-installs',  'show popularity of devices by install'
      .parse process.argv

    unless commander.runningCommand
      commander.outputHelp()
      process.exit 1

(new Command()).run()
