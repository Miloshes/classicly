(function() {
  $(function() {
    var audiobook, popularCovers, randomAudiobooks, randomBooks, totalAudiobooks, totalBooks, url;
    $('img.cover-art').each(function() {
      var addToTop, nLeft, nTop;
      if ($(this).height() < 155) {
        addToTop = 155 - $(this).height();
        nLeft = $(this).offset().left;
        nTop = $(this).offset().top + addToTop;
        return $(this).offset({
          top: nTop,
          left: nLeft
        });
      }
    });
    popularCovers = $('#right-column .row .cover-here.popular, #right-column .row .cover-with-title-here.popular');
    if ($('#right-column .row').hasClass('audiobooks')) {
      url = '/random_json_audiobooks/';
      audiobook = true;
    } else {
      url = '/random_json_books/';
    }
    $.getJSON(url + popularCovers.size(), function(data) {
      return $.each(popularCovers, function(index, value) {
        var randCover, toTake, totalCovers;
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
    randomBooks = $('.random-book');
    if (randomBooks.get(0)) {
      totalBooks = randomBooks.size();
    }
    if (randomBooks.get(0)) {
      $.getJSON('/random_json_books/' + totalBooks, function(data) {
        return $.each($('.random-book'), function(index, value) {
          var randCover, toTake, totalCovers;
          randCover = Math.floor(Math.random() * totalCovers);
          toTake = data.splice(randCover, 1);
          totalCovers = data.length;
          return setElementCover($(this), toTake);
        });
      });
    }
    randomAudiobooks = $('.random-audiobook');
    if (randomAudiobooks.get(0)) {
      totalAudiobooks = randomAudiobooks.size();
    }
    if (randomAudiobooks.get(0)) {
      return $.getJSON('/random_json_audiobooks/' + totalAudiobooks, function(data) {
        return $.each($('.random-audiobook'), function(index, value) {
          var randCover, toTake, totalCovers;
          randCover = Math.floor(Math.random() * totalCovers);
          toTake = data.splice(randCover, 1);
          totalCovers = data.length;
          return window.setCoverForAudiobook($(this), toTake);
        });
      });
    }
  });

}).call(this);
