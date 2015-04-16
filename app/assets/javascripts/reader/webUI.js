

$( function() {

  $( "a#fb_connect" ).live( "click", function(){
    FB.login( function( response ) {
      // the user successfully logs in, let's register him and notify the Library model afterwards
      if ( response.authResponse ) {
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

  $( "a#fb_decline" ).live( "click", function(){
    $( "#notification" ).hide( "blind", { direction: "vertical" }, 1000 );
    return false;
  });
});


