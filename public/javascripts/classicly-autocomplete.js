var elementId = "#term";
var slugField = "#page_slug"
var source = "search/autocomplete";
google.setOnLoadCallback(function() {
  $(function() {

    var sourceCallback = function( request, responseCallback ) {
    	$.ajax( {
    		url: source,
    		dataType: "json",
    		data: { query: request.term },
    		success: function( data ) {
    		  responseCallback( $.map( data, function( item ) {
    		    console.log( item );
    				if( item.type == 'audiobook' || item.type == 'book' )
    					return {
    						label: item.type + ' - ' + item.pretty_title,
    						value: item.pretty_title,
    						slug: item.slug
    					}
    				else
    					return {
    						label: item.type + ' - ' + item.name,
    						value: item.pretty_title,
    						slug: item.slug
    					}
    			}));
    		}
    	} );
    };

    var selectCallback = function( event, ui ) { 
    	event.target.value = ui.item.label;
    	$( slugField ).val( ui.item.slug )
    	window.location = 'http://classicly-staging.heroku.com/' + $( slugField ).val();
    };

    $( elementId ).autocomplete( {
    	source: sourceCallback,
    	minLength: 2,
    	delay: 250,
    	select: selectCallback
    } );
  }); // $ fun
}); // g callback