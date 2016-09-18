Component = require 'component'

module.exports =
Sorter = ->
    component = Component()
    sorts = []

    # Public
    component.setOrder = (sortFuncs...) ->
        sortFuncs.length
        sorts = sortFuncs

    component.drip = (stuff) ->
        entry = mem[stuff.id]

        if stuff.isDeleted
            if entry
                delete mem[stuff.id]
                stuff.sorting = action: 'remove'
                component.trigger 'drip', stuff
        else
            pos = findPosition(stuff)
            if entry
                stuff.sorting or= {}
                if entry.sorting.position == pos
                    stuff.sorting.action = 'none'
                else
                    stuff.sorting.action = 'move'
                    stuff.sorting.fromPosition = entry.sorting.position
                    stuff.sorting.position = pos
            else
                stuff.sorting = { position: pos, action: 'insert' }

            mem[stuff.id] = stuff
            component.trigger 'drip', stuff

    # Private
    findPosition = (stuff) ->
        pos = 0

        for k,v of mem
            if compare(v, stuff) < 0
                pos += 1

        return pos

    compare = (left, right, rule=0) ->
        if rule == sorts.length
            return 0

        ret = sorts[rule](left, right)

        if ret == 0
            test(left, right, rule+1)
        else
            ret

    # Constructor
    mem = {}

    # Binding
    component.registerEvents 'drip'

    component
