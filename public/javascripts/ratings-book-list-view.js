var ui = new UIHandler();
var loginsController = new LoginsController( ui );
var ratingsController = new RatingsController( loginsController, ui );

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
    loginsController.dropLoginDrawer( true );

    // store temporarily request's data. This because once the user logs in, this data will be send to create the rating:
    $( 'ul.book-list' ).data( 'selectedBookId' , bookId );
    $( 'ul.book-list' ).data( 'selectedBookRating' , value );
    LoginsController.bind( 'afterLoggedIn', afterLoggedBookListingPage );
  }
}});

$( '.rating-cancel' ).remove();
 
function afterLoggedBookListingPage(){
  if( $( "ul.book-list" ).data( "selectedBookRating" ) != undefined ){
    var bookId  = $( 'ul.book-list' ).data( 'selectedBookId');
    var value   = $( 'ul.book-list' ).data( 'selectedBookRating');
    var klass   = $( "ul.book-list" ).hasClass( "audiobooks" ) ? 'audiobook': "book";
  
    var ratingText  = "li#"+ klass + "_" + bookId + " .row .my-rating-text";
    var blankStars  = "li#"+ klass + "_" + bookId + " .row .download-link .row.stars .blank-stars";
    var rating      = "li#"+ klass + "_" + bookId + " .row .download-link .row.stars .rating";
  
    ratingsController.sendRate( bookId, value, klass, {ratingTextDOM: ratingText, blankStarsDOM: blankStars, ratingStarsDOM: rating });
  }
}