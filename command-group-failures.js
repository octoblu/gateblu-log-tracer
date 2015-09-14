#!/usr/bin/env node

var exec = require('child_process').exec;
console.log('Processing logs...');
exec('./command-group-failures.sh', function(error, stdout, stderr){
  if(error) { return console.error(error); }
  if(stderr) { return console.error(stderr); }
  console.log(stdout);
  console.log('Done!');
})
