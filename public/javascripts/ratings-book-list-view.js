$( function(){
  
  $( "#fb_connect_notification a#fb_connect" ).click( function(){
    
    FB.login(function( response ) {
      // send the rating if logged in:
      if (response.session) {
        var bookId = $( 'ul.book-list' ).data( 'selectedBookId' );
        var rating = $( 'ul.book-list' ).data( 'selectedBookRating' );
        
        sendRating( bookdId, rating );
      }
      // hide the rtegistration dropdown:
      if ( $( "#fb_connect_notification" ).is( ":visible" ) )
        $( "#fb_connect_notification ").slideUp( "slow" );
    });
    return false;
  });

});


$( 'input.dynamic-stars' ).rating({callback: function(value, link ){
  var domId = $( this ).attr( 'id' );
  var domIdSplit = domId.split( '_' );
  var bookId = domIdSplit[ domIdSplit.length - 2];
  
  var data = 'book_id=' + bookId + '&rating=' + value;

  // send the rating
  if( isLoggedIn() ){
    sendRating( bookId, value );
  }else{
    // show the registration dropdown:
    if ( $( "#fb_connect_notification" ).is( ":hidden" ) )
      $( "#fb_connect_notification ").slideDown( "slow" );

    // store temporarily request's data. This because once the user logs in, this data will be send to create the rating:
    $( 'ul.book-list' ).data( 'selectedBookId' , bookId );
    $( 'ul.book-list' ).data( 'selectedBookRating' , value );
  }
}});

// this is for the ratings plugin. It avoids showing a non useful delete icon:
$( '.rating-cancel' ).remove();

function sendRating( bookId, rating ){
  var data = 'book_id=' + bookId + '&rating=' + rating;
  
  $.ajax({
    type: 'POST',
    url: '/reviews/create_rating',
    data: data,
    beforeSend: hideStarsOnRating( bookId ),
    success: function(){
      myReviewText = $( "li#book_" + bookId + " .row .my-rating-text" );
      myReviewText.text( "Saved!" );
      setTimeout( "showStarsOnRatingCompleted(" + bookId + ")", 200 );
    }
  });
}

function hideStarsOnRating( bookId ){
  myReviewText = $( "li#book_" + bookId + " .row .my-rating-text" );
  myReviewText.text( "Saving..." );
  
  // traverse DOM:
  parent = myReviewText.parents( '.download-link' );
  stars = parent.children( '.row.stars' );
  
  stars.children( '.columns.rating ' ).hide();
  stars.children( '.columns.blank-stars' ).show();
}

function showStarsOnRatingCompleted( bookId ){
  myReviewText = $( "li#book_" + bookId + " .row .my-rating-text" );
  myReviewText.text( "My Rating:" );
  
  // traverse DOM:
  parent = myReviewText.parents( '.download-link' );
  stars = parent.children( '.row.stars' );
  
  stars.children( '.columns.rating ' ).show();
  stars.children( '.columns.blank-stars' ).hide();
}