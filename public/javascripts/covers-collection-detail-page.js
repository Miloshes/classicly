(function(){
  $(function() {
    var allIds, currentCollectionId, data;
    // =============================== FILL COLLECTION COVERS
    // let's get covers for the current collection
    // now lets get the featured collection:
    currentCollectionId = $('.featured-books').attr('name').split('_')[1];
    console.log(currentCollectionId);
    $.getJSON('json_books_for_authors_collection', {
      id: currentCollectionId
    }, function(data) {
      return $.each(data, function(index, value) {
        var bookData, selector;
        // find current collection element:
        selector = '. featured-books';
        bookData = value.books;
        // find every cover holder and fill it with the cover:
        return $.each($(selector + ' .cover-here'), function(index, value) {
          var randCover, toTake, totalCovers;
          // ATTENTION! don't remove the blank space before .cover-here
          totalCovers = bookData.length;
          randCover = Math.floor(Math.random() * totalCovers);
          toTake = bookData.splice(randCover, 1);
          if (totalCovers > 0) {
            return setElementCover($(this), toTake);
          } else {
            return $(this).remove();
            // =============================== FILL COLLECTION'S BOOKS COVERS
            // get all books's ids:
          }
        });
      });
    });
    allIds = $('ul.book-list li').map(function() {
      return $(this).attr('id').split('_')[1];
    });
    allIds = allIds.get();
    // create a single string:
    data = $(allIds).get().join(',');
    // request AJAX sending all collection ids
    return $.getJSON('json_books', {
      id: data
    }, function(data) {
      return $.each(data, function(index, value) {
        var bookData, selector;
        // find book element:
        selector = 'ul.book-list li#book_' + value.attrs.id;
        bookData = [value.attrs];
        // set the cover for this book
        return setElementCover($(selector + ' .cover-here'), bookData);
      });
    });
  });
})();
