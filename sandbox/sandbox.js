(function() {
  window.onload = function() {
    var region, regions, _i, _len, _results;
    regions = document.querySelectorAll('.edit-me');
    _results = [];
    for (_i = 0, _len = regions.length; _i < _len; _i++) {
      region = regions[_i];
      _results.push(new ContentEdit.Region(region));
    }
    return _results;
  };

}).call(this);
