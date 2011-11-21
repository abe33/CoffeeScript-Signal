requestAnimFrame = window.requestAnimationFrame 	  || 
		           window.webkitRequestAnimationFrame || 
		           window.mozRequestAnimationFrame    || 
		           window.oRequestAnimationFrame      || 
		           window.msRequestAnimationFrame     || 
		           -> 
		           	   window.setTimeout callback, 1000 / 60

class Impulse extends Signal
	constructor:(@timeScale=1)->
		super()

		@running = false
	
	add:(listener, scope, priority=0)->
		super listener, scope, priority
		if @hasListeners() and not @running then @start()
	
	remove:(listener, scope, priority=0)->
		super listener, scope, priority
		if @running and not @hasListeners() then @stop()
	
	start:->
		@running = true
		@initRun()
					
	stop:->
		@running = false
	
	initRun:->
		@time = @getTime()
		requestAnimFrame =>
			@run()
	
	hasListeners:->
		@listeners.length > 0

	getTime:->
		(new Date).getTime()
	
	run:->
		if @running
			t = @getTime()
			s = ( t - @time ) * @timeScale

			@dispatch s, s / 1000, t 
			@initRun()

if window? then window.Impulse = Impulse