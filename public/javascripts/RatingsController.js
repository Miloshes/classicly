var RatingsController = function( loginsController, uiHandler ){
  this.uiHandler = uiHandler;
  this.loginsController = loginsController;
};

var showStarsOnRatingComplete = function(){
  ratingTextDiv = $( ".cover-column #my-rating #text" );
  ratingTextDiv.text( "My Rating:" );

  // traverse DOM:
  myRating = ratingTextDiv.parents( '#my-rating' );

  myRating.children( '#rating-stars' ).show();
  myRating.children( '#blank-stars' ).hide();
};

RatingsController.prototype = {

  hideStarsOnRating: function(){
    ratingTextDiv = $( ".cover-column #my-rating #text" );
    ratingTextDiv.text( "Saving..." );

    // traverse DOM:
    myRating = ratingTextDiv.parents( '#my-rating' );

    myRating.children( '#rating-stars' ).hide();
    myRating.children( '#blank-stars' ).show();
  },

  sendRate: function( bookId, rating, klass){
    var data = klass + '_id=' + bookId + '&rating=' + rating;
    var url =  '/reviews/create_rating';

    $.ajax({
      type: 'POST',
      url: url,
      data: data,
      beforeSend: this.hideStarsOnRating(),
      success: function(){
        ratingTextDiv = $( ".cover-column #my-rating #text" );
        ratingTextDiv.text( "Saved!" );
        setTimeout( "showStarsOnRatingComplete()", 200 );
      }
    });
  }
}

