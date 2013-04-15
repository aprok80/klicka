class MouseClickGame
	width: 600
	height: 500
	targetList: null

	constructor: (width, height, targetnum )->
		console.log width
		alert 'test'
		# @createCanvas()
		@createTargets()
		# setInterval @tick, 10

	createCanvas: ->
		@canvas = document.createElement 'canvas'
		document.body.appendChild @canvas
		@canvas.height = @height;
		@canvas.width  = @width;
		@drawingContext = @canvas.getContext '2d'

	createTargets: ->

	tick: ->
		for target in targetList
			@drawTarget target

	drawTarget: ->

