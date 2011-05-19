(function(){
  $(function() {
    var allIds, data, featuredCollectionId;
    // get all collection's ids:
    allIds = $('li.collection').map(function() {
      return $(this).attr('id').split('_')[1];
    });
    allIds = allIds.get();
    // create a single string:
    data = $(allIds).get().join(',');
    // request AJAX sending all collection ids
    $.getJSON('collection_json_books', {
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
    return $.getJSON('collection_json_books', {
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
  });
})();
