var elementId = "#term";
var apiUrl =  "http://6wfx.api.indextank.com";
var indexName = "classicly_staging";
var source = apiUrl + "/v1/indexes/" + indexName + "/search";
var titles;

/* this allows us to pass in HTML tags to autocomplete. Without this they get escaped */
$[ "ui" ][ "autocomplete" ].prototype["_renderItem"] = function( ul, item) {
return $( "<li></li>" ) 
  .data( "item.autocomplete", item )
  .append( $( "<a></a>" ).html( item.label ) )
  .appendTo( ul );
};

google.setOnLoadCallback(function() {
  $(function() {
    var sourceCallback = function( request, responseCallback ) {
      titles = [];
      $.ajax( {
          url: apiUrl + "/v1/indexes/" + indexName + "/autocomplete",
          dataType: "jsonp",
          data: { query: request.term, field: 'text' },
          success: function( data ) { 
              $.ajax({
                url: source,
                dataType: "jsonp",
                data: {len:5, q:data.suggestions[0], snippet:'text', fetch: "text"},
                success: function( data ) {
                  $.map( data.results, function( item ) {
                    titles.push( item.snippet_text );
                  });
                  responseCallback( $.each( titles, function( index, value ){
                    return{ label: value, value: value }
                  })); 
                }
            })
          }
      });
    };

    var selectCallback = function( event, ui ) {
      event.target.value = ui.item.value;
      // wrap form into a jQuery object, so submit honors onsubmit.
      $(event.target.form).submit();
    }

    $( elementId ).autocomplete( {
      source: sourceCallback,
      delay: 250,
      select: selectCallback
    });
  }); // $ fun
}); // g callback
