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
    				if( item.type == 'audiobook' || item.type == 'book' )
    					return {
    						label: item.type + ' - ' + item.pretty_title,
    						value: item.slug
    					}
    				else
    					return {
    						label: item.type + ' - ' + item.name,
    						value: item.slug
    					}
    			}));
    		}
    	} );
    };

    var selectCallback = function( event, ui ) { 
    	event.target.value = ui.item.label;
    	$( slugField ).val( ui.item.value )
    	window.location = 'http://localhost:3000/' + ui.item.value;
    };

    $( elementId ).autocomplete( {
    	source: sourceCallback,
    	minLength: 2,
    	delay: 250,
    	select: selectCallback
    } );
  }); // $ fun
}); // g callback