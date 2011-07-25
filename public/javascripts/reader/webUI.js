$( function() {
  $( ".facebook_connect_reader" ).live( "click", function(){
    FB.login( function( response ) {
      // the user successfully logs in, let's register him and notify the Library model afterwards
      if ( response.session ) {
        $.ajax({
          type: "POST",
          url: "/logins",
          dataType: "json",
          success: function(data) {
            $.ajax({
              url: '/library/handle_facebook_login'
            });
          }
        });

        $( "#notification" ).slideUp( "normal" );

      }
    });

    return false;
  });
});
