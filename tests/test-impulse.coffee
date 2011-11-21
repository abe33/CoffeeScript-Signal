
module "impulse test"

test "Impulse has listeners", ->
	impulse = new Impulse
	listener = ->
	
	impulse.add listener 

	assertThat impulse, hasProperty "listeners", arrayWithLength 1

test "Impulse dispatch message to listeners", ->
	message = null
	impulse = new Impulse
	listener = ->
		message = arguments[0]
	
	impulse.add listener	
	impulse.dispatch "hello"

	assertThat message, equalTo "hello"

test "Impulse can't add twice the same listener", ->
	impulse = new Impulse
	listener = ->
	
	impulse.add listener
	impulse.add listener

	assertThat impulse.listeners, arrayWithLength 1

test "Listeners can be removed from impulse", ->
	impulse = new Impulse
	listener = ->
	
	impulse.add listener
	impulse.remove listener

	assertThat impulse.listeners, arrayWithLength 0

test "Listeners can be registered with a scope", ->
	impulse = new Impulse
	scope = {}
	listenerScope = null
	listener = ->
		listenerScope = this
	
	impulse.add listener, scope
	impulse.dispatch "hello"

	assertThat listenerScope, equalTo scope

test "The same listener can be registered twice with two different scope", ->
	impulse = new Impulse
	scope1 = {}
	scope2 = {}
	listener = ->
	
	impulse.add listener, scope1
	impulse.add listener, scope2

	assertThat impulse.listeners, arrayWithLength 2

test "Even a listener with a scope can be removed", ->
	impulse = new Impulse
	scope1 = foo:"Foo"
	scope2 = foo:"Bar"
	lastCall = null
	listener = ->
		lastCall = this.foo
	
	impulse.add listener, scope1
	impulse.add listener, scope2

	impulse.remove listener, scope1

	impulse.dispatch()

	assertThat impulse.listeners, arrayWithLength 1
	assertThat lastCall, equalTo "Bar" 

test "Listeners can be added for one call only", ->
	impulse = new Impulse
	callCount = 0
	listener = ->
		callCount++
	
	impulse.addOnce listener

	impulse.dispatch()
	impulse.dispatch()

	assertThat callCount, equalTo 1

test "Listeners can have a priority", ->
	impulse = new Impulse
	listenersCalls = []

	listener1 = ->
		listenersCalls.push "listener1"
	
	listener2 = ->
		listenersCalls.push "listener2"

	impulse.add listener1
	impulse.add listener2, null, 1

	impulse.dispatch()

	assertThat listenersCalls, array "listener2", "listener1"

test "Listeners can have a priority, even when called once", ->
	impulse = new Impulse
	listenersCalls = []

	listener1 = ->
		listenersCalls.push "listener1"
	
	listener2 = ->
		listenersCalls.push "listener2"

	impulse.add listener1
	impulse.addOnce listener2, null, 1

	impulse.dispatch()

	assertThat listenersCalls, array "listener2", "listener1"

test "Impulse can removes all its listeners at once", ->
	impulse = new Impulse

	tick1 = ->
	tick2 = ->

	impulse.add tick1
	impulse.add tick2

	impulse.removeAll()
	assertThat impulse.listeners, arrayWithLength 0

test "Impulse is running after a listener was added", ->
	impulse = new Impulse
	tick = ->

	impulse.add tick

	assertThat impulse.running

test "Impulse is no longer running after the last listeners was removed", ->
	impulse = new Impulse
	tick = ->

	impulse.add tick
	impulse.remove tick

	assertThat impulse.running, equalTo false

asyncTest "Impulse dispath itself messages when running",->

	impulse = new Impulse
	tickWasCalled = false
	tick = ->
		tickWasCalled = true
	
	impulse.add tick

	setTimeout ->
		assertThat tickWasCalled

		start()
	, 100

setTimeout ->
	asyncTest "Impulse's messages are numbers", ->

		asArray = (a)-> o for o in a   

		impulse = new Impulse
		tickArguments = null
		tick = ->
			tickArguments = asArray arguments
		
		impulse.add tick

		setTimeout ->
			assertThat tickArguments, array isA("number"), isA("number"), isA("number")

			start()
		, 100
, 200

setTimeout ->
	asyncTest "Impulse's second argument is derived from the first", ->

		asArray = (a)-> o for o in a 

		impulse = new Impulse
		tickArguments = null
		tick = ->
			tickArguments = asArray arguments
		
		impulse.add tick

		setTimeout ->
			assertThat tickArguments[1], equalTo tickArguments[0] / 1000

			start()
		, 100 
, 400 

setTimeout ->
	asyncTest "Impulse third argument is the current time (close to in fact)", ->

		asArray = (a)-> o for o in a 

		impulse = new Impulse
		tickArguments = null
		tick = ->
			tickArguments = asArray arguments
		
		impulse.add tick

		setTimeout ->
			console.log "test"
			assertThat tickArguments[2], closeTo (new Date).getTime(), 20

			start()
		, 100  
, 600

setTimeout ->
	asyncTest "Impulse can have a variable time scale", ->

		asArray = (a)-> o for o in a 

		impulseDefault = new Impulse
		tickDefaultArguments = null
		tickDefault = ->
			tickDefaultArguments = asArray arguments

		impulseDefault.add tickDefault

		impulseFaster = new Impulse 2
		tickFasterArguments = null
		tickFaster = ->
			tickFasterArguments = asArray arguments
		
		impulseFaster.add tickFaster

		setTimeout ->
			assertThat tickFasterArguments[0], closeTo tickDefaultArguments[0] * 2, 4

			start()
		, 100  
, 800

setTimeout ->
	asyncTest "Impulse can be arbitrary stopped", ->
		impulse = new Impulse		
		tickWasCalled = false

		tick = ->
			tickWasCalled = true

		impulse.add tick

		impulse.stop()

		assertThat impulse.running, equalTo false

		setTimeout ->
			assertThat tickWasCalled, equalTo false

			start()
		, 100
, 1000

setTimeout ->
	asyncTest "Impulse can be restarted when stopped", ->
		impulse = new Impulse		
		tickWasCalled = false

		tick = ->
			tickWasCalled = true

		impulse.add tick

		impulse.stop()
		impulse.start()

		assertThat impulse.running, equalTo true

		setTimeout ->
			assertThat tickWasCalled, equalTo true

			start()
		, 100
, 1000

