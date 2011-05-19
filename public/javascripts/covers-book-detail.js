(function(){
  $(function() {
    var Cover;
    Cover = function Cover() {    };
    Cover.prototype.init = function init() {
      return Cover.prototype.initCovers();
    };
    Cover.prototype.initCovers = function initCovers() {
      var bookId, totalRelatedCovers;
      bookId = $("#book-page").attr('name');
      totalRelatedCovers = $(".related").size();
      return $.getJSON('/related_books/' + bookId + '/' + totalRelatedCovers, function(data) {
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
    };
    window.Cover = new Cover();
    return window.Cover.init();
  });
})();
