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
    var totalBooks;
    totalBooks = $('.cover-here, .cover-with-title-here').size() + 3;
    return $.getJSON('/random_json_books/' + totalBooks, function(data) {
      return $.each($('.cover-here, .cover-with-title-here'), function(index, value) {
        var randCover, toTake, totalCovers;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        totalCovers = data.length;
        return setElementCover($(this), toTake);
      });
    });
  };
  window.Cover = new Cover();
  window.Cover.init();
})();
