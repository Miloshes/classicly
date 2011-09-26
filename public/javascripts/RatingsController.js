var RatingsController = function( loginsController, uiHandler ){
  this.uiHandler = uiHandler;
  this.loginsController = loginsController;
};

var showStarsOnRatingComplete = function( ratingTextDOM, ratingStarsDOM, blankStarsDOM ){
  ratingTextDiv = $( ratingTextDOM );
  ratingTextDiv.text( "My Rating:" );

  $( ratingStarsDOM ).show();
  $( blankStarsDOM ).hide();
};

RatingsController.prototype = {

  hideStarsOnRating: function(){
    ratingTextDiv = $( this.settings.ratingTextDOM );
    ratingTextDiv.text( "Saving..." );

    $( this.settings.ratingStarsDOM ).hide();
    $( this.settings.blankStarsDOM ).show();
  },

  sendRate: function( bookId, rating, klass, options){
    var data = klass + '_id=' + bookId + '&rating=' + rating;
    var url =  '/reviews/create_rating';
    
    var self = this;
    self.settings = $.extend({
      ratingTextDOM   : ".cover-column #my-rating #text",
      ratingStarsDOM  : "#my-rating #rating-stars",
      blankStarsDOM   : "#my-rating #blank-stars"
    }, options || {});
    
    $.ajax({
      type: 'POST',
      url: url,
      data: data,
      beforeSend: this.hideStarsOnRating(),
      success: function(){
        ratingTextDiv = $( self.settings.ratingTextDOM );
        ratingTextDiv.text( "Saved!" );
        setTimeout( "showStarsOnRatingComplete('"+ self.settings.ratingTextDOM + "', '" + self.settings.ratingStarsDOM +"','" + self.settings.blankStarsDOM + "')", 200 );
      }
    });
  }
}

