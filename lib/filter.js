// Generated by CoffeeScript 1.10.0
(function() {
  var Component;

  Component = require('component');

  module.exports = function() {
    var component, filter, mem;
    component = Component();
    mem = {};
    filter = function() {
      return true;
    };
    component.setFilter = function(newFilter) {
      var action, entry, k, results;
      filter = newFilter;
      results = [];
      for (k in mem) {
        entry = mem[k];
        action = filter(entry) ? 'show' : 'hide';
        if (action !== entry.filter.action) {
          entry.filter.action = action;
          if (entry.sorting) {
            entry.sorting.action = 'none';
          }
          console.log(action);
          results.push(component.trigger('drip', entry));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };
    component.drip = function(stuff) {
      if (stuff.isDeleted) {
        delete mem[stuff.id];
        return component.trigger('drip', stuff);
      } else {
        mem[stuff.id] = stuff;
        if (filter(stuff)) {
          stuff.filter = {
            action: 'show'
          };
        } else {
          stuff.filter = {
            action: 'hide'
          };
        }
        return component.trigger('drip', stuff);
      }
    };
    component.registerEvents('drip');
    return component;
  };

}).call(this);