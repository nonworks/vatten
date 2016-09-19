// Generated by CoffeeScript 1.10.0
(function() {
  var Distributary, Flow;

  Flow = require('./flow');

  module.exports = Distributary = function(ruleOrKey) {
    var component, seen;
    seen = {};
    if (typeof ruleOrKey === 'function') {
      component = Flow();
      component.drip = function(stuff) {
        var match;
        match = ruleOrKey(stuff);
        if (match) {
          seen[stuff.id] = true;
          return component.trigger('drip', stuff);
        } else {
          if (seen[stuff.id]) {
            delete seen[stuff.id];
            return component.trigger('drip', {
              id: stuff.id,
              isDeleted: true
            });
          }
        }
      };
    } else {
      component = Flow(ruleOrKey);
      component.name = ruleOrKey;
      component.drip = function(stuff) {
        if (stuff[ruleOrKey]) {
          return component.trigger('drip', stuff[ruleOrKey]);
        }
      };
    }
    return component;
  };

}).call(this);