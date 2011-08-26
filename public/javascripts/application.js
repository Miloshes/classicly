$(function(){
  var _paq = _paq || [];
});

$(function(){
  $('.audiobook-switcher a').tooltip({
    // use div.tooltip as our tooltip
    tip: '.tooltip',
    // use the fade effect instead of the default
    effect: 'fade',
    // make fadeOutSpeed similar to the browser's default
    fadeOutSpeed: 100,
    // the time before the tooltip is shown
    predelay: 0,
    // tweak the position
    position: "bottom right",
    offset: [-25, 5]
  });

  // record search events
  $( '#search #indexTankForm' ).submit( function(){
    var searchTerm = $( this ).find('#term').val();
    if( _gaq ) _gaq.push( ['_trackEvent', 'search_events', 'search', searchTerm] );
  });

  // FUNCTIONS FOR THE DROPDOWN DRAWER
  $( "#fb_connect_notification a#fb_decline" ).click( function(){
    $( "#fb_connect_notification" ).hide("blind", { direction: "vertical" }, 1000);
    return false;
  });

});

function isLoggedIn(){
  var logged = false;

  FB.getLoginStatus( function( response ) {
    if (response.status == 'connected')
      logged = true;
  });

  return logged;
}
