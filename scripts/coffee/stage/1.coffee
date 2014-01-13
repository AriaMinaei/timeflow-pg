graph = require './1/graph'
YattaGL = require 'yatta-gl'
EditorView = require 'timeflow/scripts/js/lib/EditorView'
EditorModel = require 'timeflow/scripts/js/lib/EditorModel'
setupGraphOn = require '../lib/tools/setupGraphOn'
DynamicTimeFlow = require 'timeflow/scripts/js/lib/DynamicTimeFlow'

# setup a simple YattaGL scene
canvas = document.getElementById 'canvas'
scene = new YattaGL.Scene canvas, yes
scene.bg 0, 0, 0, 0

# get a reference to the particle positions array
posArray = do ->

	# create the particle pool
	pool = new YattaGL.ParticlePool scene, count = 1, blending: 'transparent'

	# setup each particle's size and color
	pool.get().size(30).color(Math.random(), 0.5, 1, 0.8) for i in [0...count]

	# return a Float32Array pointing to the buffer containing the position data
	# of each particle
	new Float32Array pool.getBuffers().pos

# instantiate timeflow with 60fps
timeFlow = new DynamicTimeFlow 60

# attach the array containing particle positions to timeFlow
timeFlow.addArray 'particles-pos', posArray

# instantiate the UI model, and name it 'main'
editorModel = new EditorModel 'main', timeFlow

# instantiate the model's UI and put it in the body
view = new EditorView editorModel, document.body

# make sure timeflow ticks in sync with our scene
scene.eachFrame view.tick

# set up the graph on our timeFlow
setupGraphOn editorModel, graph

# and make the view visible
view.prepare()