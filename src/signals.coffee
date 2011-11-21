# Use a `Signal` object wherever you need to dispatch an event.
# A `Signal` is a dispatcher that have onnly one channel. 
#
# Signals are generally defined as property of an object. And
# their name generally end with a past tense verb, such as in:
#
#     myObject.somethingChanged
class Signal

	# Signals maintain an array of listeners.
	constructor:->
		@listeners = []
	
	#### Listeners management
	#
	# Listeners are stored internally as an array with the form:
	#
	#     [ listener, scope, calledOnce, priority ]

	# You can register a listener with or without a scope.
	# 
	# An optional `priority` arguments allow you to force
	# an order of dispatch for a listener.
	add:( listener, scope, priority = 0 )->

		# A listener can be registered several times, but only
		# if the scope object is different each time.
		#
		# In other words, the following is possible:
		#
		#     listener = ->
		#     scope = {}
		#     myObject.signal.add listener
  		#     myObject.signal.add listener, scope
		#
		# When the following is not:
		#
		#     listener = ->
		#     myObject.signal.add listener
  		#     myObject.signal.add listener
		if not @registered listener, scope 
			@listeners.push [ listener, scope, false, priority ]

			# Listeners are sorted according to their order each time
			# a new listener is added.
			if @listeners.length > 1
				@sortListeners()
	
	# Listeners can be registered for only one call.
	#
	# All the others rules are the same. So you can't add
	# the same listener/scope couple twice through the two methods.
	addOnce:( listener, scope, priority = 0 )->
		if not @registered listener, scope 
			@listeners.push [ listener, scope, true, priority ]
			if @listeners.length > 1
				@sortListeners()
	
	# Listeners can be removed, but only with the scope with which
	# they was added to the signal.
	#
	# In this regards, avoid to register listeners without a scope.
	# If later in the application a scope is forgotten or invalid 
	# when removing a listener from this signal, the listener 
	# without scope will end up being removed.
	remove:( listener, scope )->
		if @registered listener, scope
			@listeners.splice @indexOf( listener, scope ), 1
	
	# All listeners can be removed at once if needed.
	removeAll:->
		@listeners = []
	
	# `indexOf` returns the position of the listener/scope couple
	# in the listeners array.
	indexOf:( listener, scope )->
		for [ _listener, _scope ], index in @listeners
			if listener is _listener and scope is _scope then return index
		-1

	# Use the `registered` method to test whether a listener/scope couple
	# have been registered in this signal.
	registered:( listener, scope )->
		@indexOf( listener, scope ) isnt -1
	
	# The listeners are sorted according to their `priority`.
	# The higher the priority the lower the listener will be
	# in the call order.
	sortListeners:->
		@listeners.sort ( a, b )-> 
			[ pA, pB ] = [ a[3], b[3] ]

			if pA < pB then 1 else if pB < pA then -1 else 0
	
	#### Dispatch

	# Signals are dispatched to all the listeners. All the arguments
	# passed to the dispatch become the signal's message.
	#
	# Listeners registered for only one call will be removed after
	# the call.
	dispatch:->
		listeners = @listeners.concat()
		for [ listener, scope, once, priority ] in listeners
			listener.apply scope, arguments	
			if once then @remove listener, scope 
	
# Address the access restriction due to the sandboxing when used
# directly in a browser with the `text/coffeescript` mode. 
if window? then window.Signal = Signal