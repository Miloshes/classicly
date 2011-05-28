(function(){
  $(function() {
    var audiobook, bookId, totalRelatedCovers, url;
    bookId = $("#book-page").attr('name');
    totalRelatedCovers = $(".related").size();
    audiobook = $('#book-page').hasClass('audiobook');
    audiobook ? (url = '/related_audiobooks') : (url = '/related_books');
    return $.getJSON(url + '/' + bookId + '/' + totalRelatedCovers, function(data) {
      var toTake;
      // get the cover for the current book:
      toTake = data.splice(0, 1);
      audiobook ? setCoverForAudiobook($("#current-book"), toTake) : setElementCover($("#current-book"), toTake);
      // assign other covers randomly to related books
      console.log(data);
      return $.each($('.related'), function(index, value) {
        var randCover, totalCovers;
        totalCovers = data.length;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        return audiobook ? setCoverForAudiobook($(this), toTake) : setElementCover($(this), toTake);
      });
    });
  });
})();
