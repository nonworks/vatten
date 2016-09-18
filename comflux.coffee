Flow = require './flow'

module.exports =
Comflux = ->
    component = Flow()

    spouts = []
    indices = {} # [spout][index_name]
    spoutByName = {}

    # Public
    component.add = (spout, opts={}) ->
        name = getName(spout, opts)
        constraint = getConstraint(name, opts.on, opts.optional)

        if constraint
            targetSpout = null
            for s in spouts
                if s.name == constraint.target.name
                    targetSpout = s
                    break

            unless targetSpout
                throw "No source for #{constraint.target.name}, did you add it?"

            component.addIndex constraint.target.name, constraint.target.key
            component.addIndex constraint.source.name, constraint.source.key

        entry = { spout, name, constraint }
        spouts.push entry
        spoutByName[name] = entry

        bind spout, name

    component.addIndex = (spout, key) ->
        indices[spout] or= {}
        indices[spout][key] or= {}

    component.get = (spout, key, val) ->
        s = indices[spout] or throw "No such spout #{spout}"
        k = s[key] or throw "No such key #{key}"
        v = k[val]
        if v
            m = match(spout, v)
            if m and m.isDeleted
                return null
            else
                return m

    component.dumpScheme = ->
        for { spout, name, constraint } in spouts
            console.log name, constraint

    # Private
    getName = (spout, opts) ->
        name = opts.as or spout.name or throw 'Unnamed flow and no `as` option'

    getConstraint = (name, onStr, optional) ->
        if onStr
            r = onStr.match /(\w+)\s*=\s*(\w+)\.(\w+)/

            if not r
                throw "Could not match the string #{onStr}, should be {key} = {spout}.{key}"

            return {
                source: { name: name, key: r[1], optional }
                target: { name: r[2], key: r[3] }
            }

    bind = (spout, name) ->
        spout.on 'drip', (data) ->
            updateIndex(name, data)

            match(name, data)

    updateIndex = (name, data) ->
        if i=indices[name]
            for k,v of i
                (v[data[k]] or= []).push data

    match = (name, data) ->
        fill {"#{name}": data}, (matches) ->
            matches.id = matches[spouts[0].name].id

            for s in spouts
                k = s.name
                v = matches[k]

                if v == true
                    # This is just a marker that this option was optional and was not matched
                    # Remove it before sending data
                    delete matches[k]
                    continue

                if v.isDeleted
                    matches.isDeleted = true
                    break

            component.trigger 'drip', matches

    clone = (obj) ->
        out = {}
        out[k] = v for k,v of obj
        return out

    fill = (startMatches, cb) ->
        fillByGoingToTop startMatches, (partialMatches) ->
            fillByGoingToBottom partialMatches, (matches) ->
                cb(matches)

    fillByGoingToTop = (matches, cb) ->
        if matches[spouts[0].name]
            cb(matches)
            return

        source = null
        for s in spouts
            if matches[s.name]
                source = s
                break

        target = spoutByName[source.constraint.target.name]

        sourceValue = matches[source.name][source.constraint.source.key]
        hits = indices[target.name][source.constraint.target.key][sourceValue]

        if not hits
            if source.constraint.source.optional
                matches[target.name] = true
                fillByGoingToTop(matches, cb)
        else
            for hit in hits
                newMatches = clone(matches)
                newMatches[target.name] = hit
                fillByGoingToTop(newMatches, cb)

    fillByGoingToBottom = (matches, cb) ->
        source = null
        for s in spouts
            if not matches[s.name]
                source = s
                break

        unless source # All matches have already been found
            cb(matches)
            return


        targetValue = matches[source.constraint.target.name][source.constraint.target.key]
        hits = indices[source.constraint.source.name][source.constraint.source.key][targetValue]

        if not hits
            if source.constraint.source.optional
                matches[source.name] = true
                fillByGoingToBottom(matches, cb)
        else
            for hit in hits
                newMatches = clone(matches)
                newMatches[source.name] = hit
                fillByGoingToBottom(newMatches, cb)

    return component
