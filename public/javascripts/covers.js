/* DO NOT MODIFY. This file was compiled Fri, 13 May 2011 20:49:11 GMT from
 * /Users/copla201/dev/classicly-staging/app/coffeescripts/covers.coffee
 */

(function() {
  var Cover, coverURLs;
  Cover = (function() {
    function Cover() {}
    Cover.prototype.init = function() {
      Cover.prototype.initCovers();
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
    };
    Cover.prototype.initCovers = function() {
      var totalCovers;
      totalCovers = coverURLs.length;
      return $.each($('.cover-here'), function(index, value) {
        var randCover, toTake;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = coverURLs.splice(randCover, 1);
        totalCovers = coverURLs.length;
        $(this).append('<img src="' + toTake + '"/>');
        return $('.cover-here img').bind('load', function() {
          return $(this).siblings('.loader').fadeOut(200, function() {
            return $(this).siblings('img').fadeIn(1000);
          });
        });
      });
    };
    Cover.prototype.initAuthors = function() {};
    Cover.prototype.initCollections = function() {};
    return Cover;
  })();
  window.Cover = new Cover();
  coverURLs = ['http://spreadsong-book-covers.s3.amazonaws.com/book_id18847_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id87_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id2133_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id4281_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id14328_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id17776_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id7186_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id264_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id12841_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id9148_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id10_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id23229_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id18744_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id18735_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id17542_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id13887_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id18195_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id9265_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id20858_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id15791_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id15167_size3.jpg', 'http://spreadsong-book-covers.s3.amazonaws.com/book_id15167_size3.jpg'];
}).call(this);
