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
          ratingsController.sendRate( bookId, value, klass);
        }else{
          // show the registration dropdown:
          loginsController.dropLoginDrawer( true );
          LoginsController.bind( 'afterLoggedIn', rateIfRatingPresent );
          // store temporarily request's data. This because once the user logs in, this data will be send to create the rating:
          $( '#book-rating' ).data( 'bookRating' , value );
        }

      }// end callback
    });// end rating

    $( '.rating-cancel' ).remove();

  });

  function rateIfRatingPresent(){
    if( $( "#book-rating" ).data( "bookRating" ) != undefined ){
      var bookId  = $( "#book-page" ).data( "book_id" );
      var klass   = $( "#book-rating" ).data( "book_type" );
      var value   = $( "#book-rating" ).data( "bookRating" );
      ratingsController.sendRate( bookId, value, klass);
    }
  }

  // LOG THROUGH FACEBOOK
  function performLoggedInChanges(){
    // check facebook status
    if ( loginsController.userLoggedIn() ) {
      return false;
    }else{
        // no user session available, someone you dont know
          // the user successfully logs in, let's register him and notify the Library model afterwards
            // register the user via the Login model
          // $.ajax({
          //             type: "POST",
          //             url: "/logins",
          //             dataType: "json",
          //             success: function( data ) {
          // 
          //               if( $( "#fb_connect_notification" ).is( ":visible") )
          //                 $( "#fb_connect_notification" ).slideUp( "slow" );
          //               if( data.is_new_login == false )
          //                 _kmq.push(["record", "User Signed In"]);
          //               else
          //                 _kmq.push(["record", "User Signed Up"]);
          // 
          //               var bookId  = $( "#book-page" ).data( "book_id" );
          //               var klass   = $( "#book-rating" ).data( "book_type" );
          //             
          //               rateIfRatingPresent();
          //             
          //               $.ajax({ 
          //                 url: "/show_review_form",
          //                 data: klass +"_id=" + bookId,
          //                 success: function(){
          //                   $( "#review-box textarea" ).css( "background", "url(/images/new_reviews_editor.png)").css( "width" , 400 ).css( "height", 89).css( "border" , "none").css("resize", "none").css( "padding", "7px 0px 0px 7px");
          //                   $( "#write-review a" ).unbind( "click" );
          //                   $( "#write-review a" ).click(function(){
          //                     return false;
          //                   });
          //                 }
          //               });
          //             }
          //           });
    }
  }
