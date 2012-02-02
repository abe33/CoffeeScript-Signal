(function() {
  var Impulse, Signal, requestAnimFrame,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Signal = (function() {

    function Signal() {
      this.listeners = [];
    }

    Signal.prototype.add = function(listener, context, priority) {
      if (priority == null) priority = 0;
      if (!this.registered(listener, context)) {
        this.listeners.push([listener, context, false, priority]);
        if (this.listeners.length > 1) return this.sortListeners();
      }
    };

    Signal.prototype.addOnce = function(listener, context, priority) {
      if (priority == null) priority = 0;
      if (!this.registered(listener, context)) {
        this.listeners.push([listener, context, true, priority]);
        if (this.listeners.length > 1) return this.sortListeners();
      }
    };

    Signal.prototype.remove = function(listener, context) {
      if (this.registered(listener, context)) {
        return this.listeners.splice(this.indexOf(listener, context), 1);
      }
    };

    Signal.prototype.removeAll = function() {
      return this.listeners = [];
    };

    Signal.prototype.indexOf = function(listener, context) {
      var index, _context, _len, _listener, _ref, _ref2;
      _ref = this.listeners;
      for (index = 0, _len = _ref.length; index < _len; index++) {
        _ref2 = _ref[index], _listener = _ref2[0], _context = _ref2[1];
        if (listener === _listener && context === _context) return index;
      }
      return -1;
    };

    Signal.prototype.registered = function(listener, context) {
      return this.indexOf(listener, context) !== -1;
    };

    Signal.prototype.sortListeners = function() {
      return this.listeners.sort(function(a, b) {
        var pA, pB, _ref;
        _ref = [a[3], b[3]], pA = _ref[0], pB = _ref[1];
        if (pA < pB) {
          return 1;
        } else if (pB < pA) {
          return -1;
        } else {
          return 0;
        }
      });
    };

    Signal.prototype.dispatch = function() {
      var context, listener, listeners, once, priority, _i, _len, _ref, _results;
      listeners = this.listeners.concat();
      _results = [];
      for (_i = 0, _len = listeners.length; _i < _len; _i++) {
        _ref = listeners[_i], listener = _ref[0], context = _ref[1], once = _ref[2], priority = _ref[3];
        listener.apply(context, arguments);
        if (once) {
          _results.push(this.remove(listener, context));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return Signal;

  })();

  if (typeof window !== "undefined" && window !== null) window.Signal = Signal;

  requestAnimFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function() {
    return window.setTimeout(callback, 1000 / 60);
  };

  Impulse = (function(_super) {

    __extends(Impulse, _super);

    function Impulse(timeScale) {
      this.timeScale = timeScale != null ? timeScale : 1;
      Impulse.__super__.constructor.call(this);
      this.running = false;
    }

    Impulse.prototype.add = function(listener, context, priority) {
      if (priority == null) priority = 0;
      Impulse.__super__.add.call(this, listener, context, priority);
      if (this.hasListeners() && !this.running) return this.start();
    };

    Impulse.prototype.remove = function(listener, context, priority) {
      if (priority == null) priority = 0;
      Impulse.__super__.remove.call(this, listener, context, priority);
      if (this.running && !this.hasListeners()) return this.stop();
    };

    Impulse.prototype.hasListeners = function() {
      return this.listeners.length > 0;
    };

    Impulse.prototype.start = function() {
      this.running = true;
      return this.initRun();
    };

    Impulse.prototype.stop = function() {
      return this.running = false;
    };

    Impulse.prototype.initRun = function() {
      var _this = this;
      this.time = this.getTime();
      return requestAnimFrame(function() {
        return _this.run();
      });
    };

    Impulse.prototype.run = function() {
      var s, t;
      if (this.running) {
        t = this.getTime();
        s = (t - this.time) * this.timeScale;
        this.dispatch(s, s / 1000, t);
        return this.initRun();
      }
    };

    Impulse.prototype.getTime = function() {
      return (new Date).getTime();
    };

    return Impulse;

  })(Signal);

  if (typeof window !== "undefined" && window !== null) window.Impulse = Impulse;

}).call(this);
