(function() {
  $(function() {
    var audiobook, bookId, totalRelatedCovers, url;
    bookId = $("#book-page").attr('name');
    totalRelatedCovers = $(".related").size();
    audiobook = $('#book-page').hasClass('audiobook');
    if (audiobook) {
      url = '/related_audiobooks';
    } else {
      url = '/related_books';
    }
    return $.getJSON(url + '/' + bookId + '/' + totalRelatedCovers, function(data) {
      var toTake;
      toTake = data.splice(0, 1);
      if (audiobook) {
        setCoverForAudiobook($("#current-book"), toTake);
      } else {
        setElementCover($("#current-book"), toTake);
      }
      return $.each($('.related'), function(index, value) {
        var randCover, totalCovers;
        totalCovers = data.length;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        if (audiobook) {
          return setCoverForAudiobook($(this), toTake);
        } else {
          return setElementCover($(this), toTake);
        }
      });
    });
  });

}).call(this);
