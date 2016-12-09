var Component = require('component');
var Sorter;

module.exports = 
Sorter = function() {
    var component = Component();
    var sorts = [];
    var mem = {};
    var sortedList = [];
    var avoid = function() { return false };

    // Public
    component.setOrder = function() {
        if (arguments.length < 1) {
            throw "Missing operand";
        }
        sorts = Array.prototype.slice.call(arguments);
    };

    component.avoid = function(func) { 
        avoid = func;
    };

    component.drip = function(stuff) {
        if (stuff.isDeleted) {
            remove(stuff)
        } else {
            if (mem[stuff.id]) {
                move(stuff);
            } else {
                insert(stuff);
            }
        }
    };

    // Private
    var remove = function (stuff) {
        var entry = mem[stuff.id];
        
        if (entry) {
            delete mem[stuff.id];
            stuff.sorting = {
                action: 'remove'
            };
            component.trigger('drip', stuff);
        }
    };

    var move = function(stuff) {
        var entry = mem[stuff.id];
        var pos;

        delete mem[stuff.id];
        pos = findPosition(stuff);

        stuff.sorting || (stuff.sorting = {});
        if (entry.sorting.position === pos) {
            stuff.sorting.action = 'none';
        } else {
            stuff.sorting.action = 'move';
            stuff.sorting.fromPosition = entry.sorting.position;
            stuff.sorting.position = pos;
        }

    };

    var insert = function(stuff) {
        var pos = findPosition(stuff);

        stuff.sorting = {
            position: pos,
            action: 'insert'
        };

        mem[stuff.id] = stuff;
        sortedList.splice(pos, 0, stuff);
        component.trigger('drip', stuff);
    };

    var findPosition = function(stuff) {
        var length = sortedList.length;
        var divider = Math.ceil(length / 2);
        var pos = Math.floor(length / 2);

        if (length == 0) {
            return 0;
        }
        if (compare(sortedList[0], stuff) >= 0) {
            return 0;
        }

        while (divider > 0) {
            divider = Math.floor(divider / 2);

            if (compare(sortedList[pos], stuff) < 0) {
                pos += (divider || 1);
            } else {
                pos -= divider;
            }
        }

        return pos;
    };
    var compare = function(left, right, rule) {
        var ret;
        if (rule == null) {
            rule = 0;
        }
        if (rule === sorts.length) {
            return 0;
        }
        ret = sorts[rule](left, right);
        if (ret === 0) {
            return test(left, right, rule + 1);
        } else {
            return ret;
        }
    };
    component.registerEvents('drip');
    return component;
};
