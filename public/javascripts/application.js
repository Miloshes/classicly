$(function(){
  var _paq = _paq || [];
});


function coversForRelatedBooks() {
  var allIds, data;
  // get all books's ids:
  allIds = $('ul.book-list li').map(function() {
    return $(this).attr('id').split('_')[1];
  });
  allIds = allIds.get();
  // create a single string:
  data = $(allIds).get().join(',');
  // request AJAX sending all collection ids
  return $.getJSON('json_books', {
    id: data
  }, function(data) {
    return $.each(data, function(index, value) {
      var bookData, selector;
      // find book element:
      selector = 'ul.book-list li#book_' + value.attrs.id;
      bookData = [value.attrs];
      // set the cover for this book
      return setElementCover($(selector + ' .cover-here'), bookData);
    });
  });
};

function setElementCover(element, toTake) {
  element.children('.stable').append('<img src="http://spreadsong-book-covers.s3.amazonaws.com/book_id' + toTake[0].id + '_size3.jpg"/>');
  element.wrap('<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">');
  element.hasClass('cover-with-title-here') ? element.append('<div class="text" style="display:none"><span class="title">' + toTake[0].pretty_title + '</span><span class="type">Book</span></div>') : null;
  $('.cover-here img, .cover-with-title-here img').bind('load', function() {
    $(this).siblings('.spinner').fadeOut(200, function() {
      $(this).parents().siblings('.text').fadeIn(1000);
      $(this).siblings('img').fadeIn(1000);});
  });
}

function setCoverForAudiobook(element, toTake) {
  element.children('.stable').append('<img src="http://spreadsong-audiobook-covers.s3.amazonaws.com/audiobook_id' + toTake[0].id + '_size3.jpg"/>');
  element.wrap('<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">');
  element.hasClass('cover-with-title-here') ? element.append('<div class="text" style="display:none"><span class="title">' + toTake[0].pretty_title + '</span><span class="type">Audiobook</span></div>') : null;
  $('.cover-here img, .cover-with-title-here img').bind('load', function() {
    $(this).siblings('.spinner').fadeOut(200, function() {
      $(this).parents().siblings('.text').fadeIn(1000);
      $(this).siblings('img').fadeIn(1000);});
  });
}

