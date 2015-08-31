commander   = require 'commander'
packageJSON = require './package.json'

class Command
  run: =>
    commander
      .version packageJSON.version
      .command 'trace', 'trace a flow deployment'
      .parse process.argv

    unless commander.runningCommand
      commander.outputHelp()
      process.exit 1

(new Command()).run()
