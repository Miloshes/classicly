var ui = new UIHandler();
var loginsController = new LoginsController( ui );
var ratingsController = new RatingsController( loginsController, ui );

$( function(){
  
  $( "#fb_connect_notification a#fb_connect" ).click( function(){
    
    FB.login(function( response ) {
      // send the rating if logged in:
      if (response.session) {
        var bookId = $( 'ul.book-list' ).data( 'selectedBookId' );
        var rating = $( 'ul.book-list' ).data( 'selectedBookRating' );
        
        sendRating( bookId, rating );
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
  
  var klass = $( "ul.book-list" ).hasClass( "audiobooks" ) ? 'audiobook': "book";
  
  var ratingText  = "li#"+ klass + "_" + bookId + " .row .my-rating-text";
  var blankStars  = "li#"+ klass + "_" + bookId + " .row .download-link .row.stars .blank-stars";
  var rating      = "li#"+ klass + "_" + bookId + " .row .download-link .row.stars .rating";
  
  // send the rating
  if( loginsController.userLoggedIn() ){
    ratingsController.sendRate( bookId, value, klass, {ratingTextDOM: ratingText, blankStarsDOM: blankStars, ratingStarsDOM: rating });
  }else{
    // show the registration dropdown:
    //if ( $( "#fb_connect_notification" ).is( ":hidden" ) )
      //$( "#fb_connect_notification ").slideDown( "slow" );

    // store temporarily request's data. This because once the user logs in, this data will be send to create the rating:
    //$( 'ul.book-list' ).data( 'selectedBookId' , bookId );
    //$( 'ul.book-list' ).data( 'selectedBookRating' , value );
  }
}});

// this is for the ratings plugin. It avoids showing a non useful delete icon:
$( '.rating-cancel' ).remove();

