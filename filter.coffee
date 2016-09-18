Component = require 'component'

module.exports = ->
    component = Component()
    mem = {}
    filter = -> true

    # Public
    component.setFilter = (newFilter) ->
        filter = newFilter

        for k,entry of mem
            action = if filter(entry) then 'show' else 'hide'
            if action != entry.filter.action
                entry.filter.action = action
                if entry.sorting
                    # This is to prevent a past 'insert' message to be repeated
                    entry.sorting.action = 'none'
                console.log action
                component.trigger 'drip', entry


    component.drip = (stuff) ->
        if stuff.isDeleted
            delete mem[stuff.id]
            component.trigger 'drip', stuff
        else
            mem[stuff.id] = stuff
            if filter(stuff)
                stuff.filter = action: 'show'
            else
                stuff.filter = action: 'hide'

            component.trigger 'drip', stuff

    # Private

    # Binding
    component.registerEvents 'drip'

    component
