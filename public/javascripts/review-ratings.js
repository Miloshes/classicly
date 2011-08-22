$( function(){
    // RATINGS
    $( 'input.star' ).rating('readOnly', true);
    $( 'input.dynamic-stars' ).rating({
      callback: function(value, link){
        var bookId =  $( '#book-page' ).attr( 'name' );
        var data = 'book_id=' + bookId + '&rating=' + value;

        // send the rating
        $.ajax({
          type: 'POST',
          url: '/ratings',
          data: data,
          success: function(){
          }
        });

      }// end callback
    });// end rating

    $( '.rating-cancel' ).remove();


    // REVIEWS
    $( '#write-review a' ).click( function(){
      writeReview();
      return false;
    });


    $( '#submit-review a' ).click( function(){
      var content = $( '#review-box textarea' ).val();
      var book_id = $( '#book-page' ).attr( 'name' );
      var data = 'review[content]=' + content;

      $.ajax({
        type: 'POST',
        url: '/books/' + book_id + '/reviews',
        data: data,
        success: function(){
          // show the new review
        }
      });

    });

  });


  // LOG THROUGH FACEBOOK
  function writeReview(){
    // check facebook status
    FB.getLoginStatus(function(response) {
      if (response.authResponse) {
        // logged in. This should not have been called.

      }else{
        console.log("You are not logged in!");
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

                if( data.is_new_login == false )
                  _kmq.push(["record", "User Signed In"]);
                else
                  _kmq.push(["record", "User Signed Up"]);

                // notify the Library model about the new registration
                $.ajax({ url: '#{library_handle_facebook_login_url}'});
              }
            });
          }
        });
      }
    });
  }
