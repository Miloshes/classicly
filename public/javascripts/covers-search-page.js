(function(){
  $(function() {
    var allIds, data, domElements, totalCovers;
    // fetch covers for found books
    domElements = $('ul.book-list li');
    // get all collection's ids:
    allIds = domElements.map(function() {
      return $(this).attr('id').split('_')[1];
    });
    allIds = allIds.get();
    // create a single string:
    data = $(allIds).get().join(',');
    totalCovers = domElements.size();
    return $.getJSON('/json_books/', {
      id: data
    }, function(data) {
      return $.each(data, function(index, value) {
        var id, selector, toTake;
        id = value.attrs.id;
        selector = 'ul.book-list li#book_' + id + ' .cover-here';
        toTake = [value.attrs];
        return setElementCover($(selector), toTake);
      });
    });
  });
})();
