(function(){
  $(function() {
    var allIds, data, domElements;
    // fetch found books ids
    domElements = $('.related .book-cover');
    // get all collection's ids:
    allIds = domElements.map(function() {
      return $(this).attr('id').split('_')[1];
    });
    allIds = unique(allIds.get());
    // create a single string:
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
})();
