Flow = require './flow'

module.exports =
Distributary = (ruleOrKey) ->
    seen = {}

    # Public
    if typeof ruleOrKey is 'function'
        component = Flow()

        component.drip = (stuff) ->
            match = ruleOrKey(stuff)

            if match
                seen[stuff.id] = true
                component.trigger('drip', stuff)
            else
                # If this was previously let through, we need to delete it
                if seen[stuff.id]
                    delete seen[stuff.id]
                    component.trigger 'drip', { id: stuff.id, isDeleted: true }


    else
        component = Flow(ruleOrKey)

        component.name = ruleOrKey
        component.drip = (stuff) ->
            component.trigger('drip', stuff[ruleOrKey]) if stuff[ruleOrKey]

    # Binding

    component
