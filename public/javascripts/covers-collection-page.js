(function(){
  $(function() {
    var allIds, data, featuredCollectionId, totalPopularCovers;
    // align small sized covers to the bottom in the related books container
    $('img.cover-art').each(function() {
      var addToTop, left, nLeft, nTop, top;
      if ($(this).height() < 155) {
        addToTop = 155 - $(this).height();
        nLeft = $(this).offset().left;
        nTop = $(this).offset().top + addToTop;
        return $(this).offset((top = nTop), (left = nLeft));
      }
    });
    // get all collection's ids:
    allIds = $('li.collection').map(function() {
      return $(this).attr('id').split('_')[1];
    });
    allIds = allIds.get();
    // create a single string:
    data = $(allIds).get().join(',');
    // request AJAX sending all collection ids
    $.getJSON('json_books_for_authors_collection', {
      id: data
    }, function(data) {
      return $.each(data, function(index, value) {
        var bookData, selector;
        // find collection element:
        selector = 'li.collection#collection_' + value.collection_id;
        bookData = value.books;
        // find every cover holder and fill it with the cover:
        return $.each($(selector + ' .cover-here'), function(index, value) {
          var randCover, toTake, totalCovers;
          // ATTENTION! don't remove the blank space before .cover-here
          totalCovers = bookData.length;
          randCover = Math.floor(Math.random() * totalCovers);
          toTake = bookData.splice(randCover, 1);
          return totalCovers > 0 ? setElementCover($(this), toTake) : $(this).remove();
        });
      });
    });
    //now lets get the featured collection:
    featuredCollectionId = $('#featured-collection').attr('name').split('_')[1];
    $.getJSON('json_books_for_authors_collection', {
      id: featuredCollectionId
    }, function(data) {
      return $.each(data, function(index, value) {
        var bookData, selector;
        // find featured collection element:
        selector = '#featured-collection';
        bookData = value.books;
        // find every cover holder and fill it with the cover:
        return $.each($(selector + ' .cover-here'), function(index, value) {
          var randCover, toTake, totalCovers;
          // ATTENTION! don't remove the blank space before .cover-here
          totalCovers = bookData.length;
          randCover = Math.floor(Math.random() * totalCovers);
          toTake = bookData.splice(randCover, 1);
          return totalCovers > 0 ? setElementCover($(this), toTake) : $(this).remove();
        });
      });
    });
    // finally, fill up the popular covers
    totalPopularCovers = $('#right-column .row .cover-here, #right-column .row .cover-with-title-here').size();
    return $.getJSON('/random_json_books/' + totalPopularCovers, function(data) {
      return $.each($('#right-column .row .cover-here, #right-column .row .cover-with-title-here'), function(index, value) {
        var randCover, toTake, totalCovers;
        totalCovers = data.length;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        return setElementCover($(this), toTake);
      });
    });
  });
})();
