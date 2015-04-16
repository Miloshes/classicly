(function() {
  $(function() {
    var audiobooks, currentCollectionId, params;
    currentCollectionId = $('.featured-books').attr('name').split('_')[1];
    audiobooks = $('.featured-books').hasClass('audiobooks');
    if (audiobooks) {
      params = {
        id: currentCollectionId,
        type: 'audiobook'
      };
    } else {
      params = {
        id: currentCollectionId
      };
    }
    $.getJSON('/collection_json_books', params, function(data) {
      return $.each(data, function(index, value) {
        var bookData, selector;
        selector = '.featured-books';
        bookData = value.books;
        return $.each($(selector + ' .cover-here'), function(index, value) {
          var randCover, toTake, totalCovers;
          totalCovers = bookData.length;
          randCover = Math.floor(Math.random() * totalCovers);
          toTake = bookData.splice(randCover, 1);
          if (totalCovers > 0) {
            if (audiobooks) {
              return setCoverForAudiobook($(this), toTake);
            } else {
              return setElementCover($(this), toTake);
            }
          } else {
            return $(this).remove();
          }
        });
      });
    });
    return coversForRelatedBooks();
  });

}).call(this);
