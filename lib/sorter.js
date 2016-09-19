// Generated by CoffeeScript 1.10.0
(function() {
  var Component, Sorter,
    slice = [].slice;

  Component = require('component');

  module.exports = Sorter = function() {
    var compare, component, findPosition, mem, sorts;
    component = Component();
    sorts = [];
    component.setOrder = function() {
      var sortFuncs;
      sortFuncs = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      sortFuncs.length;
      return sorts = sortFuncs;
    };
    component.drip = function(stuff) {
      var entry, pos;
      entry = mem[stuff.id];
      if (stuff.isDeleted) {
        if (entry) {
          delete mem[stuff.id];
          stuff.sorting = {
            action: 'remove'
          };
          return component.trigger('drip', stuff);
        }
      } else {
        pos = findPosition(stuff);
        if (entry) {
          stuff.sorting || (stuff.sorting = {});
          if (entry.sorting.position === pos) {
            stuff.sorting.action = 'none';
          } else {
            stuff.sorting.action = 'move';
            stuff.sorting.fromPosition = entry.sorting.position;
            stuff.sorting.position = pos;
          }
        } else {
          stuff.sorting = {
            position: pos,
            action: 'insert'
          };
        }
        mem[stuff.id] = stuff;
        return component.trigger('drip', stuff);
      }
    };
    findPosition = function(stuff) {
      var k, pos, v;
      pos = 0;
      for (k in mem) {
        v = mem[k];
        if (compare(v, stuff) < 0) {
          pos += 1;
        }
      }
      return pos;
    };
    compare = function(left, right, rule) {
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
    mem = {};
    component.registerEvents('drip');
    return component;
  };

}).call(this);