(function(){
  // all functions in this file are bound to the Window object to make em global.
  $(function() {
    window.compressText = function compressText(text, threshold) {
      var newText;
      if (text.length < threshold) {
        return text;
      }
      newText = text.substring(0, (threshold - 2));
      return newText + '...';
    };
    window.setElementCover = function setElementCover(element, toTake) {
      var threshold;
      element.children('.stable').append('<img src="http://spreadsong-book-covers.s3.amazonaws.com/book_id' + toTake[0].id + '_size3.jpg"/>');
      //element.wrap '<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">'
      if (element.hasClass('cover-with-title-here')) {
        threshold = element.hasClass('small' || element.hasClass('tiny')) ? 40 : 61;
        element.append('<div class="text" style="display:none"><span class="title">' + compressText(toTake[0].pretty_title, threshold) + '</span><span class="type">Book</span></div>');
      }
      return $('.cover-here img, .cover-with-title-here img').bind('load', function() {
        return $(this).siblings('.spinner').fadeOut(200, function() {
          $(this).parents().siblings('.text').fadeIn(1000);
          return $(this).siblings('img').fadeIn(1000).wrap('<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">');
        });
      });
    };
    window.setCoverForAudiobook = function setCoverForAudiobook(element, toTake) {
      var threshold;
      element.children('.stable').append('<a "/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline"><img src="http://spreadsong-audiobook-covers.s3.amazonaws.com/audiobook_id' + toTake[0].id + '_size3.jpg"/></a>');
      //element.wrap '<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">'
      if (element.hasClass('cover-with-title-here')) {
        threshold = element.hasClass('small' || element.hasClass('tiny')) ? 40 : 61;
        element.append('<div class="text" style="display:none"><span class="title">' + compressText(toTake[0].pretty_title, threshold) + '</span><span class="type">Audiobook</span></div>');
      }
      return $('.cover-here img, .cover-with-title-here img').bind('load', function() {
        return $(this).siblings('.spinner').fadeOut(200, function() {
          $(this).parents().siblings('.text').fadeIn(1000);
          return $(this).siblings('a').fadeIn(1000);
        });
      });
    };
    return window.coversForRelatedBooks = function coversForRelatedBooks() {
      var allIds, audiobooks, data, url;
      allIds = $('ul.book-list li').map(function() {
        return $(this).attr('id').split('_')[1];
      });
      allIds = allIds.get();
      //determine if we are going to fetch audiobooks or books
      audiobooks = $('ul.book-list').hasClass('audiobooks');
      url = audiobooks ? 'json_audiobooks' : 'json_books';
      //create a single string:
      data = $(allIds).get().join(',');
      return $.getJSON(url, {
        id: data
      }, function(data) {
        return $.each(data, function(index, value) {
          var bookData, selector, str;
          //find book element:
          bookData = [value.attrs];
          str = audiobooks ? 'ul.book-list li#audiobook_' : ' ul.book-list li#book_';
          selector = str + value.attrs.id + ' .cover-here';
          //set the cover for this book
          return audiobooks ? setCoverForAudiobook($(selector), bookData) : setElementCover($(selector), bookData);
        });
      });
    };
  });
})();
