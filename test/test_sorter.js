chai = require('chai');
chai.Should();

var Sorter = require('../lib/sorter');

describe('sorter', function () {
    
    it('should sort based on order function', function(){
        var list = [];
        var sorter = Sorter();

        sorter.setOrder(function(one,two) {
            if (one.number < two.number) {
                return -1
            } else {
                return 1
            }
        });

        sorter.on('drip', function(thing) {
            var pos = thing.sorting.position;

            list.splice(pos, 0, thing.number);
        });

        sorter.drip({ id: 2, number: 25 });
        sorter.drip({ id: 3, number: 75 });
        sorter.drip({ id: 5, number: 5 });
        sorter.drip({ id: 1, number: 50 });
        sorter.drip({ id: 4, number: 85 });

        list.should.be.deep.equal([5, 25, 50, 75, 85]);
    });

});
