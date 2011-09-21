$( function(){

    $('#signin a').click(function(){
      if($("#fb_connect_notification").hasClass('fixed')){
        $("#fb_connect_notification").removeClass('fixed');
      }
    });
    
    $( '#write-review a, #signin a' ).click( function(){
      dropLoginDrawer();
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
        
        if( isLoggedIn() ){ // send the rating.
          sendRatingIndividualBookPage( bookId, value, klass );
        }else{
          // show the registration dropdown:
          if ( $( "#fb_connect_notification" ).is( ":hidden" ) )
            $( "#fb_connect_notification ").slideDown( "slow" );

          // store temporarily request's data. This because once the user logs in, this data will be send to create the rating:
          $( '#book-rating' ).data( 'bookRating' , value );
        }
        
      }// end callback
    });// end rating

    $( '.rating-cancel' ).remove();

    // LOG IN
    $( "#fb_connect_notification a#fb_connect" ).click( function(){
      performLoggedInChanges();
      return false;
    });

  });

  function bookPageHideStarsOnRating(){
    ratingTextDiv = $( ".cover-column #my-rating #text" );
    ratingTextDiv.text( "Saving..." );

    // traverse DOM:
    myRating = ratingTextDiv.parents( '#my-rating' );

    myRating.children( '#rating-stars' ).hide();
    myRating.children( '#blank-stars' ).show();
  }

  function bookPageShowStarsOnRatingCompleted(){
    ratingTextDiv = $( ".cover-column #my-rating #text" );
    ratingTextDiv.text( "My Rating:" );

    // traverse DOM:
    myRating = ratingTextDiv.parents( '#my-rating' );

    myRating.children( '#rating-stars' ).show();
    myRating.children( '#blank-stars' ).hide();
  }
  
  function sendRatingIndividualBookPage( bookId, rating, klass ){
    var data = klass + '_id=' + bookId + '&rating=' + rating;

    $.ajax({
      type: 'POST',
      url: '/reviews/create_rating',
      data: data,
      beforeSend: bookPageHideStarsOnRating(),
      success: function(){
        ratingTextDiv = $( ".cover-column #my-rating #text" );
        ratingTextDiv.text( "Saved!" );
        setTimeout( "bookPageShowStarsOnRatingCompleted()", 200 );
      }
    });
  }

  function rateIfRatingPresent(){
    if( $( "#book-rating" ).data( "bookRating" ) != undefined ){
      var bookId  = $( "#book-page" ).data( "book_id" );
      var klass   = $( "#book-rating" ).data( "book_type" );
      var value   = $( "#book-rating" ).data( "bookRating" );
      sendRatingIndividualBookPage( bookId, value, klass ) ;
    }
  }
  
  function dropLoginDrawer(){
    FB.getLoginStatus(function(response) {
      if (response.status == 'connected')
        // logged in. This should not have been called.
          return false;
      else
        if ( $( "#fb_connect_notification" ).is( ":hidden" ) )
          $( "#fb_connect_notification ").slideDown( "slow" );

    });
  }

  // LOG THROUGH FACEBOOK
  function performLoggedInChanges(){
    // check facebook status
    if ( isLoggedIn() ) {
      return false;
    }else{
        // no user session available, someone you dont know
      FB.login( function( response ) {
          // the user successfully logs in, let's register him and notify the Library model afterwards
        if (response.session) {
            // register the user via the Login model
          $.ajax({
            type: "POST",
            url: "/logins",
            dataType: "json",
            success: function( data ) {

              if( $( "#fb_connect_notification" ).is( ":visible") )
                $( "#fb_connect_notification" ).slideUp( "slow" );
              if( data.is_new_login == false )
                _kmq.push(["record", "User Signed In"]);
              else
                _kmq.push(["record", "User Signed Up"]);

              var bookId  = $( "#book-page" ).data( "book_id" );
              var klass   = $( "#book-rating" ).data( "book_type" );
              
              rateIfRatingPresent();
              
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
          });
        }
      });
    }
  }
