canvas = document.getElementById 'canvas'

YattaGL = require 'yatta-gl'
ParticlePool = YattaGL.ParticlePool

scene = new YattaGL.Scene canvas, yes

scene.bg 0, 0, 0, 0

EditorView = require 'timeflow/scripts/js/lib/EditorView'
EditorModel = require 'timeflow/scripts/js/lib/EditorModel'
DynamicTimeFlow = require 'timeflow/scripts/js/lib/DynamicTimeFlow'

setupTimeFlow = ->

	posArray = do ->

		pool = new ParticlePool scene, count = 1, blending: 'transparent'

		pool.get().size(30).color(Math.random(), 0.5, 1, 0.8) for i in [0...count]

		new Float32Array pool.getBuffers().pos

	timeFlow = new DynamicTimeFlow 60

	# preparing the arrays
	timeFlow.addArray 'pos', posArray
	timeFlow.addArray 'p-p', new Float32Array 5

	timeFlow

setupDummyGraphOn = (editorModel) ->

	graph =

		'TYPOGRAPHY': [
			'Prequel'
			# '“Like a Dog Chasing Cars”'
			'Hans’s Interview - Part 1'
			'Hans’s Interview - Part 2'
			'Origins of The Track'
			# '“...one of the highlights”'
		]

		'SNOW PHYSICS': [
			'Drag'
			'Horizontal Gravity'
			'Wind'
			'Generator'
		]

		'LIGHTING': [
			'Centeral Point'
			'Bottom Illuminator'
			'Ambiance'
			'Shadow Tint'
		]

		'CINEMATOGRAPHY': [
			'View Selector'
			'Pers Cam'
			'Tele Cam'
		]

		'BACKGROUND': [
			'“Rise”'
			'The Gradient'
			'Clouds Controller'
		]

		'AUDIO': [
			'Music Track'
			'Ambient Track'
		]

	for name, actors of graph

		cat = editorModel.graph.getCategory name

		cat.getActor name for name in actors

	return

setupRealGraphOn = (editorModel) ->

	# Directorals Category
	directorals = editorModel.graph.getCategory 'Directorals'
	box1 = directorals.getActor 'Box 1'
	box1X = box1.addProp 'Position X', 'pos', 0
	box1Y = box1.addProp 'Position Y', 'pos', 1

	# Post-Processing Category
	postProcessing = editorModel.graph.getCategory 'Post-Processing'
	blurEffect = postProcessing.getActor 'Blur Effect'
	blurRadius = blurEffect.addProp 'Radius', 'p-p', 0
	shakeEffect = postProcessing.getActor 'Shake Effect'
	shakeIntentsity = shakeEffect.addProp 'Intensity', 'p-p', 1
	shakeDirectionX = shakeEffect.addProp 'Direction X', 'p-p', 2
	shakeDirectionY = shakeEffect.addProp 'Direction Y', 'p-p', 2

	return box1X: box1X, box1Y: box1Y

setupDefaultWorkspacesOn = (editorModel, box1X, box1Y) ->

	# These lists can be created dynamically, but we can also create them
	# here
	cinematic = editorModel.workspaces.get 'Cinematic'

	cinematic.addProp box1X
	cinematic.addProp box1Y

	cinematic.activate()

	# postProcessingWs = editorModel.workspaces.get 'Post-Processing'
	# postProcessingWs.addProp shakeDirectionX
	# postProcessingWs.addProp shakeDirectionY
	# postProcessingWs.addProp blurRadius
	# postProcessingWs.addProp shakeIntentsity

setupPacsOn = (editorModel, box1X, box1Y) ->

	box1XProp = box1X.timeFlowProp
	pacs = box1XProp.pacs

	pacs.addPoint 1500,	0,			100,		300,		300,		150
	pacs.addPoint 3500,	120,		300,		300,		300,		120

	pacs.addPoint 3800,	180,		55,		1,			55,		1
	pacs.addPoint 3900,	185,		55,		100,		55,		1
	pacs.addPoint 4000,	120,		55,		1,			55,		1

	pacs.addConnector 1500
	pacs.done()

	pacs = box1Y.timeFlowProp.pacs

	pacs.addPoint 1000, 50, 90, 110, 90, 10
	pacs.addPoint 1500, -50, 90, 110, 90, 15
	pacs.addConnector 1000
	pacs.addPoint 2500, 90, 90, 110, 90, 15
	pacs.addConnector 1500

	pacs.addPoint 2900, 0, 90, 110, 90, 10
	pacs.addPoint 3500, 0, 90, -110, 90, 10
	pacs.addPoint 3800, 0, 90, -110, 90, 10
	pacs.addPoint 4100, 0, 90, -110, 90, 10
	pacs.addConnector 2900
	pacs.addConnector 3500
	pacs.addConnector 3800

	pacs.done()

setupDataIndependentStuff = ->

	timeFlow = do setupTimeFlow

	editorModel = new EditorModel 'main', timeFlow
	view = new EditorView Math.random(), document.body, editorModel

	# make sure timeflow ticks in sync with our scene
	scene.eachFrame view.tick

	setupDummyGraphOn editorModel

	{box1X, box1Y} = setupRealGraphOn editorModel

	# done with the static stuff, let's fire up the view
	view.prepare()

	{editorModel, view, box1X, box1Y}

setupAndGetSerialized = (cb) ->

	{editorModel, view, box1X, box1Y} = setupDataIndependentStuff()

	setupDefaultWorkspacesOn editorModel, box1X, box1Y

	setupPacsOn editorModel, box1X, box1Y

	setTimeout ->

		editorModel.timeControl.tick 2500
		cb view, editorModel.serialize()

	, 0

setupWithSerializedData = (serialized) ->

	{editorModel, view, box1X, box1Y} = setupDataIndependentStuff()

	serialized = JSON.parse JSON.stringify serialized

	setTimeout ->

		editorModel.loadFrom serialized

	, 0

setupAndGetSerialized (oldView, serialized) ->

	oldView.node.quit()
	setupWithSerializedData serialized