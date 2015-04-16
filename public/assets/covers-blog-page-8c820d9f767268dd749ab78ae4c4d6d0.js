(function() {
  $(function() {
    var allIds, data, domElements;
    domElements = $('.related .book-cover');
    allIds = domElements.map(function() {
      return $(this).attr('id').split('_')[1];
    });
    allIds = unique(allIds.get());
    data = $(allIds).get().join(',');
    return $.getJSON('/json_books/', {
      id: data
    }, function(data) {
      return $.each(data, function(index, value) {
        var id, selector, toTake;
        id = value.attrs.id;
        selector = '.related .book-cover#book_' + id + ' .cover-here';
        toTake = [value.attrs];
        return setElementCover($(selector), toTake);
      });
    });
  });

}).call(this);
