(function(){
  $(function() {
    var bookId, totalRelatedCovers;
    bookId = $("#download-confirmation-page").attr('name');
    totalRelatedCovers = $("#download-confirmation-page .related").size();
    return $.getJSON('/related_books/' + bookId + '/' + totalRelatedCovers, function(data) {
      return $.each($('#download-confirmation-page .related'), function(index, value) {
        var randCover, toTake, totalCovers;
        totalCovers = data.length;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        return setElementCover($(this), toTake);
      });
    });
  });
})();
