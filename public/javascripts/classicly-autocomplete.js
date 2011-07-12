var elementId = "#term";
var apiUrl =  "http://6wfx.api.indextank.com";
var indexName = "ClassiclyAutocomplete";
var source = apiUrl + "/v1/indexes/" + indexName + "/search";
var searchResults;

/* this allows us to pass in HTML tags to autocomplete. Without this, they get escaped */

$[ "ui" ][ "autocomplete" ].prototype["_renderItem"] = function( ul, item) {
return $( "<li></li>" ) 
  .data( "item.autocomplete", item )
  .append( $( "<a></a>" ).html( item.label + "<span class='type'>" + item.type + "</span>" ) )
  .appendTo( ul );
};


google.setOnLoadCallback(function() {
  $(function() {
    var sourceCallback = function( request, responseCallback ) {
      searchResults = [];
      $.ajax( {
          url: apiUrl + "/v1/indexes/" + indexName + "/autocomplete",
          dataType: "jsonp",
          data: { query: request.term, field: 'text' },
          success: function( data ) { 
              $.ajax({
                url: source,
                dataType: "jsonp",
                data: {len: 10, q:data.suggestions[0], snippet:'text', fetch: "text,type,slug"},
                success: function( data ) {
                  $.map( data.results, function( item ) {
                    console.log( item.slug );
                    searchResults.push( { label : item.snippet_text, value : item.text, type : item.type, slug : item.slug  } );
                  });
                  responseCallback( $.each( searchResults, function( index, result ){
                    return{ label: result.label, value: result.value }
                  })); 
                }
            })
          }
      });
    };

    var selectCallback = function( event, ui ) {
      event.target.value = ui.item.value;
      window.location = "http://classicly-staging.heroku.com" + ui.item.slug;
      // wrap form into a jQuery object, so submit honors onsubmit.
      //$(event.target.form).submit();
    }

    $( elementId ).autocomplete( {
      source: sourceCallback,
      delay: 250,
      select: selectCallback
    });
  }); // $ fun
}); // g callback
