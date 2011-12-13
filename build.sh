#!/bin/sh
coffee --join signals.js --compile src/signals.coffee src/impulse.coffee 
docco src/*.coffee
