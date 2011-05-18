(function(){
  $(function() {
    var allIds, currentCollectionId, data, totalPopularCovers;
    // align small sized covers to the bottom in the related books container
    $('img.cover-art').each(function() {
      var addToTop, left, nLeft, nTop, top;
      if ($(this).height() < 155) {
        addToTop = 155 - $(this).height();
        nLeft = $(this).offset().left;
        nTop = $(this).offset().top + addToTop;
        return $(this).offset((top = nTop), (left = nLeft));
        // =============================== FILL COLLECTION COVERS
        // let's get covers for the current collection
        // now lets get the featured collection:
      }
    });
    currentCollectionId = $('.featured-books').attr('name').split('_')[1];
    console.log(currentCollectionId);
    $.getJSON('json_books_for_authors_collection', {
      id: currentCollectionId
    }, function(data) {
      return $.each(data, function(index, value) {
        var bookData, selector;
        // find current collection element:
        selector = '.featured-books';
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
            // =============================== FILL POPULAR BOOKS COVERS
            // fill up the popular book covers
          }
        });
      });
    });
    totalPopularCovers = $('#right-column .row .cover-here, #right-column .row .cover-with-title-here').size();
    $.getJSON('/random_json_books/' + totalPopularCovers, function(data) {
      return $.each($('#right-column .row .cover-here, #right-column .row .cover-with-title-here'), function(index, value) {
        var randCover, toTake, totalCovers;
        totalCovers = data.length;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        return setElementCover($(this), toTake);
      });
    });
    // =============================== FILL COLLECTION'S BOOKS COVERS
    // get all books's ids:
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
