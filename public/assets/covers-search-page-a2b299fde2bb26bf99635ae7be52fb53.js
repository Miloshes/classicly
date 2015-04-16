(function() {
  $(function() {
    var allIds, audiobooks, data, domElements, totalCovers, url;
    domElements = $('ul.book-list li');
    audiobooks = $('ul.book-list').hasClass('audiobooks');
    url = audiobooks ? '/json_audiobooks' : '/json_books';
    allIds = domElements.map(function() {
      return $(this).attr('id').split('_')[1];
    });
    allIds = allIds.get();
    data = $(allIds).get().join(',');
    totalCovers = domElements.size();
    return $.getJSON(url, {
      id: data
    }, function(data) {
      return $.each(data, function(index, value) {
        var id, selector, toTake;
        id = value.attrs.id;
        selector = 'ul.book-list li#book_' + id + ' .cover-here';
        toTake = [value.attrs];
        if (audiobooks) {
          return setCoverForAudiobook($(selector), toTake);
        } else {
          return setElementCover($(selector), toTake);
        }
      });
    });
  });

}).call(this);
