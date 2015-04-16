// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require jquery
//= require jquery-ui
//= require jquery.markitup
//= require jquery.markitup.set
//= require jquery.metadata
//= require jquery.json-2.2.min
//= require UIHandler
//= require LoginsController
//= require_self
//= require global.js
//= require classicly-autocomplete
//= require rails.js
//= require notifications.js
//= require jquery.lazyload.min

//= require_tree .

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
});


function sendKissMetricsEvent( event, attributes ){
  if( _kmq ){
    if( attributes )
      _kmq.push( ["record", event, attributes ] );
    else
      _kmq.push( ["record", event] );
  }

}


