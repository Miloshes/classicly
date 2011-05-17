(function(){
  $(function() {
    var Cover;
    Cover = function Cover() {    };
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
      var bookId, totalPopularCovers, totalRelatedCovers;
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
      totalPopularCovers = $('#right-column .row .cover-here, #right-column .row .cover-with-title-here').size();
      return $.getJSON('/random_json_books/' + totalPopularCovers, function(data) {
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
    return window.Cover.init();
  });
})();
