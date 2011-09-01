$( 'input.dynamic-stars' ).rating({callback: function(value, link ){
  var domId = $( this ).attr( 'id' );
  var domIdSplit = domId.split( '_' );
  var bookId = domIdSplit[ domIdSplit.length - 2];
  
  var data = 'book_id=' + bookId + '&rating=' + value;

  // send the rating
  $.ajax({
    type: 'POST',
    url: '/reviews/create_rating',
    data: data,
    success: function(){
    }
  });
}});

$( '.rating-cancel' ).remove();