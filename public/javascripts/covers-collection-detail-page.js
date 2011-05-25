(function(){
  $(function() {
    var audiobooks, currentCollectionId, params;
    // =============================== FILL COLLECTION COVERS
    // let's get covers for the current collection:
    currentCollectionId = $('.featured-books').attr('name').split('_')[1];
    audiobooks = $('.featured-books').hasClass('audiobooks');
    audiobooks ? (params = {
      id: currentCollectionId,
      type: 'audiobook'
    }) : (params = {
      id: currentCollectionId
    });
    $.getJSON('collection_json_books', params, function(data) {
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
            return audiobooks ? setCoverForAudiobook($(this), toTake) : setElementCover($(this), toTake);
          } else {
            return $(this).remove();
            // =============================== FILL COLLECTION'S BOOKS COVERS
          }
        });
      });
    });
    return coversForRelatedBooks();
  });
})();
