var uiHandler = new UIHandler();
var loginsController = new LoginsController( uiHandler );
var ratingsController = new RatingsController( loginsController, uiHandler );

$( function(){

    $( '#write-review a' ).click( function(){
      loginsController.dropLoginDrawer( true );
      return false;
    });

    $( '#submit-review a' ).live( 'click', function(){
      sendKissMetricsEvent( "Review Submitted" );
      $('#review-box form').submit();
      return false;
    });

    $("#reviews div:nth-child(odd).individual_review").addClass("striped");

    // RATINGS
    $( 'input.dynamic-stars' ).rating({
      callback: function(value, link){
        var bookId  = $( "#book-page" ).data( "book_id" );
        var klass   = $( "#book-rating" ).data( "book_type" );

        if( loginsController.userLoggedIn() ){ // send the rating.
          ratingsController.sendRate( bookId, value, klass, {});
        }else{
          $( '#book-rating' ).data( 'bookRating' , value );
          // show the registration dropdown:
          loginsController.dropLoginDrawer( true );
          LoginsController.bind( 'afterLoggedIn', afterLoggedIndividualBookPage );
          // store temporarily request's data. This because once the user logs in, this data will be send to create the rating:
        }

      }// end callback
    });// end rating

    $( '.rating-cancel' ).remove();

  });

  function afterLoggedIndividualBookPage(){
    var bookId  = $( "#book-page" ).data( "book_id" );
    var klass   = $( "#book-rating" ).data( "book_type" );
    rateIfRatingPresent( bookId, klass );
    showForm( bookId, klass );
  }
  
  function rateIfRatingPresent(bookId, klass){
    if( $( "#book-rating" ).data( "bookRating" ) != undefined ){
      var value   = $( "#book-rating" ).data( "bookRating" );
      ratingsController.sendRate( bookId, value, klass, {}); //we sent the rating and use the default options
    }
  }
  
  function showForm(bookId, klass){
    $.ajax({ 
      url: "/show_review_form",
      data: klass +"_id=" + bookId,
      success: function(){
        $( "#review-box textarea" ).css( "background", "url(/images/new_reviews_editor.png)").css( "width" , 400 ).css( "height", 89).css( "border" , "none").css("resize", "none").css( "padding", "7px 0px 0px 7px");
        $( "#write-review a" ).unbind( "click" );
        $( "#write-review a" ).click(function(){
          return false;
        });
      }
    });
  }
;
