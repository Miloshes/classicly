(function() {
  $(function() {
    var collections;
    collections = $(".collection-here, .collection-with-title-here");
    return $.each(collections, function(index, value) {
      var audiobooks, collection, collectionId, covers;
      collection = $(this);
      collectionId = collection.attr('name');
      audiobooks = collection.hasClass('audiobooks');
      covers = collection.children('.cover-here');
      return $.getJSON('/collection_json_books', {
        id: collectionId,
        total_books: covers.size()
      }, function(data) {
        collection.append('<div class="text"><a href="' + data[0].collection_slug + '"><span class="title">' + data[0].collection_name + '</span></a><span class="type">Collection</span></div>');
        return $.each(data, function(index, value) {
          var bookData;
          bookData = value.books;
          return $.each(covers, function(index, value) {
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
    });
  });

}).call(this);
