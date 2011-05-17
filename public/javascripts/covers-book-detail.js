(function(){
  var Cover, setElementCover;
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
    var bookId, totalRelatedCovers;
    bookId = $("#book-page").attr('name');
    totalRelatedCovers = $(".related").size();
    $.getJSON('/related_books/' + bookId + '/' + totalRelatedCovers, function(data) {
      var toTake;
      // get the cover for the current book:
      toTake = data.splice(0, 1);
      setElementCover($("#current-book"), toTake);
      // assign other covers randomly to related books
      return $.each($('.related'), function(index, value) {
        var randCover, totalCovers;
        totalCovers = data.length;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        return setElementCover($(this), toTake);
      });
    });
    return $.getJSON('/random_json_books/3', function(data) {
      return $.each($('#right-column .row .cover-here, #right-column .row .cover-with-title-here'), function(index, value) {
        var randCover, toTake, totalCovers;
        totalCovers = data.length;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        return setElementCover($(this), toTake);
      });
    });
  };
  window.Cover = new Cover();
  window.Cover.init();
  setElementCover = function setElementCover(element, toTake) {
    element.children('.stable').append('<img src="http://spreadsong-book-covers.s3.amazonaws.com/book_id' + toTake[0].id + '_size3.jpg"/>');
    element.wrap('<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">');
    element.hasClass('cover-with-title-here') ? element.append('<div class="text" style="display:none"><span class="title">' + toTake[0].pretty_title + '</span><span class="type">Book</span></div>') : null;
    return $('.cover-here img, .cover-with-title-here img').bind('load', function() {
      return $(this).siblings('.spinner').fadeOut(200, function() {
        $(this).parents().siblings('.text').fadeIn(1000);
        return $(this).siblings('img').fadeIn(1000);
      });
    });
  };
})();
