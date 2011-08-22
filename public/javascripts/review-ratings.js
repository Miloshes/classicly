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


    $( '#submit-review a' ).live( 'click', function(){
      $('#review-box form').submit();
      return false;
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

                var bookId = $( '#book-page' ).attr( 'name' );
                $.ajax({ 
                  url: '/show_review_form',
                  data: 'book_id=' + bookId
                });
              }
            });
          }
        });
      }
    });
  }