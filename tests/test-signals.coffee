module "signals test"

test "Signal has listeners", ->
	signal = new Signal
	listener = ->
	
	signal.add listener 

	assertThat signal, hasProperty "listeners", arrayWithLength 1

test "Signal dispatch message to listeners", ->
	message = null
	signal = new Signal
	listener = ->
		message = arguments[0]
	
	signal.add listener	
	signal.dispatch "hello"

	assertThat message, equalTo "hello"

test "Signal can't add twice the same listener", ->
	signal = new Signal
	listener = ->
	
	signal.add listener
	signal.add listener

	assertThat signal.listeners, arrayWithLength 1

test "Listeners can be removed from signal", ->
	signal = new Signal
	listener = ->
	
	signal.add listener
	signal.remove listener

	assertThat signal.listeners, arrayWithLength 0

test "Listeners can be registered with a context", ->
	signal = new Signal
	context = {}
	listenerScope = null
	listener = ->
		listenerScope = this
	
	signal.add listener, context
	signal.dispatch "hello"

	assertThat listenerScope, equalTo context

test "The same listener can be registered twice with two different context", ->
	signal = new Signal
	context1 = {}
	context2 = {}
	listener = ->
	
	signal.add listener, context1
	signal.add listener, context2

	assertThat signal.listeners, arrayWithLength 2

test "Even a listener with a context can be removed", ->
	signal = new Signal
	context1 = foo:"Foo"
	context2 = foo:"Bar"
	lastCall = null
	listener = ->
		lastCall = this.foo
	
	signal.add listener, context1
	signal.add listener, context2

	signal.remove listener, context1

	signal.dispatch()

	assertThat signal.listeners, arrayWithLength 1
	assertThat lastCall, equalTo "Bar" 

test "Listeners can be added for one call only", ->
	signal = new Signal
	callCount = 0
	listener = ->
		callCount++
	
	signal.addOnce listener

	signal.dispatch()
	signal.dispatch()

	assertThat callCount, equalTo 1

test "Listeners can have a priority", ->
	signal = new Signal
	listenersCalls = []

	listener1 = ->
		listenersCalls.push "listener1"
	
	listener2 = ->
		listenersCalls.push "listener2"

	signal.add listener1
	signal.add listener2, null, 1

	signal.dispatch()

	assertThat listenersCalls, array "listener2", "listener1"

test "Listeners can have a priority, even when called once", ->
	signal = new Signal
	listenersCalls = []

	listener1 = ->
		listenersCalls.push "listener1"
	
	listener2 = ->
		listenersCalls.push "listener2"

	signal.add listener1
	signal.addOnce listener2, null, 1

	signal.dispatch()

	assertThat listenersCalls, array "listener2", "listener1"

test "Signals can removes all its listeners at once", ->
	signal = new Signal

	listener1 = ->
	listener2 = ->

	signal.add listener1
	signal.add listener2

	signal.removeAll()
	assertThat signal.listeners, arrayWithLength 0
