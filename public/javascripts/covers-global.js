(function(){
  $(function() {
    var totalPopularCovers;
    // align small sized covers to the bottom in the related books container
    $('img.cover-art').each(function() {
      var addToTop, left, nLeft, nTop, top;
      if ($(this).height() < 155) {
        addToTop = 155 - $(this).height();
        nLeft = $(this).offset().left;
        nTop = $(this).offset().top + addToTop;
        return $(this).offset((top = nTop), (left = nLeft));
        // =============================== FILL POPULAR BOOKS COVERS
        // fill up the popular book covers
      }
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
  });
})();
