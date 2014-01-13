object = require 'utila/scripts/js/lib/object'

module.exports = setupGraphOn = (editorModel, graph) ->

	for categoryName, actors of graph

		cat = editorModel.graph.getCategory categoryName

		for actorName, props of actors

			actor = cat.getActor actorName

			if object.isBareObject props

				for propName, propSettings of props

					if object.isBareObject propSettings

						actor.addProp propName, propSettings.arrayName, propSettings.arrayIndex

					else

						throw Error "For now, only bare object prop settings are supported. Invalid: prop: '#{propName}' on actor: '#{actorName}'"

	return