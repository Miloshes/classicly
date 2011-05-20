(function(){
  $(function() {
    var Cover;
    Cover = function Cover() {    };
    Cover.prototype.init = function init() {
      return Cover.prototype.initCovers();
    };
    Cover.prototype.initCovers = function initCovers() {
      var totalBooks;
      totalBooks = $('.random-book').size();
      return $.getJSON('/random_json_books/' + totalBooks, function(data) {
        return $.each($('.random-book'), function(index, value) {
          var randCover, toTake, totalCovers;
          randCover = Math.floor(Math.random() * totalCovers);
          toTake = data.splice(randCover, 1);
          totalCovers = data.length;
          return setElementCover($(this), toTake);
        });
      });
    };
    window.Cover = new Cover();
    return window.Cover.init();
  });
})();
