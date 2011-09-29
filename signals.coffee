class Signal
	constructor:->
		@listeners = []
	
	add:( listener, scope, priority = 0 )->
		if not @registered listener, scope 
			@listeners.push [ listener, scope, false, priority ]
			if @listeners.length > 1
				@sortListeners()
	
	addOnce:( listener, scope, priority = 0 )->
		if not @registered listener, scope 
			@listeners.push [ listener, scope, true, priority ]
			if @listeners.length > 1
				@sortListeners()

	remove:( listener, scope )->
		if @registered listener, scope
			@listeners.splice @indexOf( listener, scope ), 1
	
	dispatch:->
		listeners = @listeners.concat()
		for [ listener, scope, once, priority ] in listeners
			listener.apply scope, arguments	
			if once then @remove listener, scope 
	
	indexOf:(listener, scope)->
		for [ _listener, _scope ], index in @listeners
			if listener is _listener and scope is _scope then return index
		-1
		
	registered:( listener, scope )->
		@indexOf( listener, scope ) isnt -1
	
	sortListeners:->
		@listeners.sort ( a, b )-> 
			[ pA, pB ] = [ a[3], b[3] ]

			if pA < pB then 1 else if pB < pA then -1 else 0

if window?
	window.Signal = Signal