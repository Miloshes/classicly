(function(){
  var Cover;
  Cover = function Cover() {  };
  Cover.prototype.init = function init() {
    Cover.prototype.initCovers();
    // align small sized covers to the bottom in the related books container
    return $('img.cover-art').each(function() {
      var addToTop, left, nLeft, nTop, top;
      if ($(this).height() < 155) {
        addToTop = 155 - $(this).height();
        nLeft = $(this).offset().left;
        nTop = $(this).offset().top + addToTop;
        return $(this).offset((top = nTop), (left = nLeft));
      }
    });
  };
  Cover.prototype.initCovers = function initCovers() {
    return $.getJSON('/home_page_books_for_author', function(data) {
      return $.each($('.cover-here, .cover-with-title-here'), function(index, value) {
        var randCover, toTake, totalCovers;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        totalCovers = data.length;
        $(this).children('.stable').append('<img src="http://spreadsong-book-covers.s3.amazonaws.com/book_id' + toTake[0].id + '_size3.jpg"/>');
        $(this).wrap('<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">');
        $(this).hasClass('cover-with-title-here') ? $(this).append('<div class="text" style="display:none"><span class="title">' + toTake[0].pretty_title + '</span><span class="type">Book</span></div>') : null;
        return $('.cover-here img, .cover-with-title-here img').bind('load', function() {
          return $(this).siblings('.spinner').fadeOut(200, function() {
            $(this).parents().siblings('.text').fadeIn(1000);
            return $(this).siblings('img').fadeIn(1000);
          });
        });
      });
    });
  };
  window.Cover = new Cover();
})();
