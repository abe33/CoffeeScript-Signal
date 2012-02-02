# <link rel="stylesheet" href="../css/styles.css" media="screen">
# Impulse is an animation signal, and rely on the `requestAnimationFrame`
# API of HTML5 to work.
#
# The `Impulse` signal has its own messages to dispatch.
#
# *Callback arguments*
#
#  * `bias`           : The duration of the last animation frame in milliseconds.
#  * `biasInSeconds`  : The duration of the last animation frame in seconds.
#  * `time`           : The current time at the moment of the call.
#
# Impulse dispatch its messages on a regular basis, based
# on the `requestAnimationFrame` function.

# Defines a local `requestAnimationFrame` function using the snippets
# from [Paul Irish](http://paulirish.com/2011/requestanimationframe-for-smart-animating/).
requestAnimFrame = window.requestAnimationFrame       or 
                   window.webkitRequestAnimationFrame or 
                   window.mozRequestAnimationFrame    or
                   window.oRequestAnimationFrame      or 
                   window.msRequestAnimationFrame     or 
                   -> 
                       window.setTimeout callback, 1000 / 60

# Impulse is a custom signal whose purpose is to handle
# animations within an application.
class Impulse extends Signal
    # Initialize the `Impulse` signal with a specific time scale.
    # By default the `timeScale` is `1`, which means there's no scaling.
    constructor:( @timeScale=1 )->
        super()

        @running = false
    
    #### Listeners management

    # Impulse listeners are registered as any other signal listeners.
    add:( listener, context, priority=0 )->
        super listener, context, priority

        # By convention, the `Impulse` signal start running when the
        # first listener is added.
        if @hasListeners() and not @running then @start()
    
    # Impulse listeners are unregistered as any other signal listeners.
    remove:( listener, context, priority=0 )->
        super listener, context, priority

        # The `Impulse` object automatically stop itself when it doesn't
        # have a listener anymore.
        if @running and not @hasListeners() then @stop()
    
    # Returns `true` is the `Impulse` as at least one listener.
    hasListeners:->
        @listeners.length > 0
    
    #### Animation controls

    # Starts, or restarts the `Impulse`.
    start:->
        @running = true
        @initRun()
        
    # Stops the `Impulse`.          
    stop:->
        @running = false
    
    # Initialize the run of the `Impulse`. A request
    # is made to the `requestAnimationFrame` that will
    # call the `run` method each time. 
    initRun:->
        @time = @getTime()
        requestAnimFrame =>
            @run()
    
    # A running `Impulse` will dispatch various informations
    # to its listeners each time the `run` method is called.
    #
    # The `initRun` is called at the end of the function if the impulse is always running
    # in order to continue the animation.
    run:->
        if @running
            t = @getTime()
            s = ( t - @time ) * @timeScale

            @dispatch s, s / 1000, t 
            @initRun()
    
    # Helper method that return the current time.
    getTime:->
        (new Date).getTime()
    

# Address the access restriction due to the sandboxing when used
# directly in a browser with the `text/coffeescript` mode. 
if window? then window.Impulse = Impulse