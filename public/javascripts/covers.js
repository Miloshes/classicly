(function() {
  var coverURLs;
  window.Covers = {
    init: function() {
      Covers.initCovers();
      return $('img.cover-art').each(function() {
        var addToTop, nLeft, nTop;
        if ($(this).height() < 155) {
          addToTop = 155 - $(this).height();
          nLeft = $(this).offset().left;
          nTop = $(this).offset().top + addToTop;
          return $(this).offset({
            top: nTop,
            left: nLeft
          });
        }
      });
    },
    initCovers: function() {
      var totalCovers;
      totalCovers = coverURLs.length;
      $('.cover-here img').bind('load', function() {
        return $(this).fadeIn(1100);
      });
      return $.each($('.cover-here img'), function(index, value) {
        var toTake;
        toTake = Math.floor(Math.random() * totalCovers);
        return $(this).append('<img src="' + coverURLs.splice(toTake + '" />'));
      });
    },
    initAuthors: function() {},
    initCollections: function() {}
  };
  coverURLs = ['http://spreadsong-book-covers.s3.amazonaws.com/book_id18847_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id87_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id2133_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id4281_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id14328_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id17776_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id7186_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id264_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id12841_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id9148_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id10_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id23229_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id18744_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id18735_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id17542_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id13887_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id18195_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id9265_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id20858_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id15791_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id15167_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id15167_size3.jpg'];
}).call(this);
