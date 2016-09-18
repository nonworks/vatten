module.exports =
Flow = (name) ->
    component = Event()
    component.name = name
    eventOn = component.on

    # Public
    component.treat = (func) ->
        newFlow = Flow(name)
        component.on 'drip', (stuff) ->
            func(stuff)
            newFlow.trigger 'drip', stuff
        newFlow.get = component.get # In case there is a dam available
        return newFlow

    component.distribute = (rule) ->
        d = Distributary(rule)

        component.on 'drip', (stuff) ->
            d.drip(stuff)

        return d

    component.comflux = (spouts...) ->
        firstOpts = {}
        unless spouts[0].pop?
            firstOpts = spouts.shift()

        c = Comflux()

        c.add component, firstOpts
        for [spout, opts] in spouts
            c.add spout, opts

        return c

    component.createFilter = ->
        f = Filter()
        component.on 'drip', f.drip
        f

    # Binding
    component.registerEvents 'drip'

    component

Event = require 'event'
Distributary = require './distributary'
Comflux = require './comflux'
Filter = require './filter'

