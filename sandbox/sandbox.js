(function() {
  window.onload = function() {
    var fixture, fixtures, region, regions, _i, _j, _len, _len1, _results;
    regions = document.querySelectorAll('.edit-me');
    for (_i = 0, _len = regions.length; _i < _len; _i++) {
      region = regions[_i];
      new ContentEdit.Region(region);
    }
    fixtures = document.querySelectorAll('.fixture');
    _results = [];
    for (_j = 0, _len1 = fixtures.length; _j < _len1; _j++) {
      fixture = fixtures[_j];
      _results.push(new ContentEdit.Fixture(fixture));
    }
    return _results;
  };

}).call(this);
