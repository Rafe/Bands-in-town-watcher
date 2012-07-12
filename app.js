require('coffee-script');
config = require('./config')

var Watcher = require('./app/watcher');

new Watcher(config).start()
