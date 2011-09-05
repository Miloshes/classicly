
 $(function(){
  // react when the user clicks the button for the library upsell:
  $('a#register-button').click( function(){
      // push the upsell viewed event into kissmetrics
    if( _gaq ) _gaq.push([ '_trackEvent', 'registrations', 'add_library', 'reg_button_clicked' ]);

    if ( $( "#fb_connect_notification" ).is( ":hidden" ) ){
      $( "#fb_connect_notification ").slideDown( "slow" );
      sendKissMetricsEvent( "Registration Dropdown Viewed");
    }

    return false;
  });

  $( "#fb_connect_notification a#fb_connect" ).click( function(){
    upsellLibrary();
    return false;
  });

  $( 'a#fb_decline' ).click( function(){
    window.location = '/';
  });

});


function upsellLibrary(){
  FB.login( function( response ) {
    sendKissMetricsEvent( "Registration Dropdown Clicked" );
  // the user successfully logs in, let's register him and notify the Library model afterwards
    if ( response.session ) {
      sendKissMetricsEvent( "Registration Dropdown Clicked" );

      // register the user via the Login model
      $.ajax({
        type: "POST",
        url: "/logins",
        dataType: "json",
        success: function( data ) {
          if( data.is_new_login == false )
            sendKissMetricsEvent( "User Signed In" );
          else
            sendKissMetricsEvent( "User Signed Up" );

          if ( $( "#fb_connect_notification" ).is( ":visible" ) )
            $( "#fb_connect_notification ").slideUp( "slow" );

          // notify the Library model about the new registration
          $.ajax({
            url: '/library/handle_facebook_login'
          });
        }
      });

    } else {
      if ( _gaq ) _gaq.push( ['_trackEvent', 'registrations', 'add_library', 'reg_canceled'] );
    }
  });
}
