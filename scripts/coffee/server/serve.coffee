PrettyError = require 'pretty-error'

pe = new PrettyError

process.on 'uncaughtException', (e) ->

	pe.render e, yes

	console.log "-----------------------\n"

	process.exit(1)

prettyWhenMonitor = require 'pretty-monitor'

prettyWhenMonitor 100

Server = require 'timeflow/scripts/coffee/lib/Server'

path = require 'path'

repoPath = path.join path.dirname(module.filename), '../../../'

process.nextTick ->

	console.log "\n-----------------------\n"

	s = new Server repoPath, 3097, 'timelines'

	console.log "\n-----------------------\n"