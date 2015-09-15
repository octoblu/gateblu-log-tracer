#!/usr/bin/env node

var exec = require('child_process').exec;
var path = require('path');

console.log('Processing logs...');
var commandPath = path.join(__dirname, '/command-group-failures.sh');
exec(commandPath, function(error, stdout, stderr){
  if(error) { return console.error(error); }
  if(stderr) { return console.error(stderr); }
  console.log(stdout);
  console.log('Done!');
})
