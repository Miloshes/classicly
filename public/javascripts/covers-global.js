(function(){
  $(function() {
    var randomAudiobooks, randomBooks, totalAudiobooks, totalBooks, totalPopularCovers;
    // align small sized covers to the bottom in the related books container
    $('img.cover-art').each(function() {
      var addToTop, left, nLeft, nTop, top;
      if ($(this).height() < 155) {
        addToTop = 155 - $(this).height();
        nLeft = $(this).offset().left;
        nTop = $(this).offset().top + addToTop;
        return $(this).offset((top = nTop), (left = nLeft));
        // =============================== FILL POPULAR BOOKS COVERS:
        // fill up the popular book covers
      }
    });
    totalPopularCovers = $('#right-column .row .cover-here, #right-column .row .cover-with-title-here').size();
    $.getJSON('/random_json_books/' + totalPopularCovers, function(data) {
      return $.each($('#right-column .row .cover-here, #right-column .row .cover-with-title-here'), function(index, value) {
        var randCover, toTake, totalCovers;
        totalCovers = data.length;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        return setElementCover($(this), toTake);
        //=============================== FILL RANDOM BOOK COVERS (Main Page) IF EXIST:
      });
    });
    randomBooks = $('.random-book');
    if (randomBooks.get(0)) {
      totalBooks = randomBooks.size();
    }
    randomBooks.get(0) ? $.getJSON('/random_json_books/' + totalBooks, function(data) {
      return $.each($('.random-book'), function(index, value) {
        var randCover, toTake, totalCovers;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        totalCovers = data.length;
        return setElementCover($(this), toTake);
        // ============================= FILL RANDOM AUDIOBOOK COVERS IF DEFINED
      });
    }) : null;
    randomAudiobooks = $('.random-audiobook');
    if (randomAudiobooks.get(0)) {
      totalAudiobooks = randomAudiobooks.size();
    }
    return randomAudiobooks.get(0) ? $.getJSON('/random_json_audiobooks/' + totalAudiobooks, function(data) {
      return $.each($('.random-audiobook'), function(index, value) {
        var randCover, toTake, totalCovers;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        totalCovers = data.length;
        return window.setCoverForAudiobook($(this), toTake);
      });
    }) : null;
  });
})();
