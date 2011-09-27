var uiHandler = new UIHandler();
var loginsController = new LoginsController( uiHandler );

$(function(){

  $( "#signin a" ).click( function(){
    loginsController.dropLoginDrawer( false );
    return false;
  });

  $( "#fb_connect_notification a#fb_connect" ).click( function(){
    loginsController.logIn();
    return false;
  });

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
    loginsController.hideLoginDrawer();
    return false;
  });

  // DISABLE CURRENT PAGE AND GAP IN PAGINATOR
  $( ".pagination ul li.active, .pagination ul li.gap" ).live( "click", function(){
    return false;
  });

  // SIGNIN
});


function sendKissMetricsEvent( event, attributes ){
  if( _kmq ){
    if( attributes )
      _kmq.push( ["record", event, attributes ] );
    else
      _kmq.push( ["record", event] );
  }

}


