(function() {
  $(function() {
    window.compressText = function(text, threshold) {
      var newText;
      if (text.length < threshold) {
        return text;
      }
      newText = text.substring(0, threshold - 2);
      return newText + '...';
    };
    window.setElementCover = function(element, toTake) {
      var anchor, threshold;
      anchor = '<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">';
      element.children('.stable').append(anchor + '<img src="http://spreadsong-book-covers.s3.amazonaws.com/book_id' + toTake[0].id + '_size3.jpg"/></a>');
      if (element.hasClass('cover-with-title-here')) {
        threshold = element.hasClass('small' || element.hasClass('tiny')) ? 40 : 61;
        element.append('<div class="text" style="display:none"> ' + anchor + '<span class="title">' + compressText(toTake[0].pretty_title, threshold) + '</span></a><span class="type">Book</span></div>');
      }
      return $('.cover-here img, .cover-with-title-here img').bind('load', function() {
        return $(this).parents('a').siblings('.spinner').fadeOut(200, function() {
          $(this).parents().siblings('.text').fadeIn(1000);
          return $(this).siblings('a').children('img').fadeIn(1000);
        });
      });
    };
    window.setCoverForAudiobook = function(element, toTake) {
      var anchor, threshold;
      anchor = '<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">';
      element.children('.stable').append(anchor + '<img src="http://spreadsong-audiobook-covers.s3.amazonaws.com/audiobook_id' + toTake[0].id + '_size3.jpg"/></a>');
      if (element.hasClass('cover-with-title-here')) {
        threshold = element.hasClass('small' || element.hasClass('tiny')) ? 40 : 61;
        element.append('<div class="text" style="display:none">' + anchor + '<span class="title">' + compressText(toTake[0].pretty_title, threshold) + '</span></a><span class="type">Audiobook</span></div>');
      }
      return $('.cover-here img, .cover-with-title-here img').bind('load', function() {
        return $(this).parents('a').siblings('.spinner').fadeOut(200, function() {
          $(this).parents().siblings('.text').fadeIn(1000);
          return $(this).siblings('a').children('img').fadeIn(1000);
        });
      });
    };
    return window.coversForRelatedBooks = function() {
      var allIds, audiobooks, data, url;
      allIds = $('ul.book-list li').map(function() {
        return $(this).attr('id').split('_')[1];
      });
      allIds = allIds.get();
      audiobooks = $('ul.book-list').hasClass('audiobooks');
      url = audiobooks ? '/json_audiobooks' : '/json_books';
      data = $(allIds).get().join(',');
      return $.getJSON(url, {
        id: data
      }, function(data) {
        return $.each(data, function(index, value) {
          var bookData, selector, str;
          bookData = [value.attrs];
          str = audiobooks ? 'ul.book-list li#audiobook_' : ' ul.book-list li#book_';
          selector = str + value.attrs.id + ' .cover-here';
          if (audiobooks) {
            return setCoverForAudiobook($(selector), bookData);
          } else {
            return setElementCover($(selector), bookData);
          }
        });
      });
    };
  });

}).call(this);
