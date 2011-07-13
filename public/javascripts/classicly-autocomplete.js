$(function(){
  $("ul.ui-autocomplete li.ui-menu-item:has('img')").each(function(){
    newHeight = $(this).find("img").height();
    $(this).height(newHeight + 4);
  });
});


var elementId = "#term";
var apiUrl =  "http://6wfx.api.indextank.com";
var indexName = "ClassiclyAutocomplete";
var source = apiUrl + "/v1/indexes/" + indexName + "/search";
var searchResults;

/* this allows us to pass in HTML tags to autocomplete. Without this, they get escaped */

$[ "ui" ][ "autocomplete" ].prototype["_renderItem"] = function( ul, item) {
var html;
if( item.type == "book" || item.type == "audiobook"){
html =  "<div class='with-cover'><img src='" + item.cover_url + "'class='micro-cover'><span class='text'>" + item.label + "<span class='type'>" + item.type + "</span></span></div>";
}else{
  html =  item.label + "<span class='type'>" + item.type + "</span>";
}
return $( "<li></li>" ) 
  .data( "item.autocomplete", item )
  .append( $( "<a></a>" ).html( html ) )
  .appendTo( ul );
}


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
                data: {len: 10, q:data.suggestions[0], snippet:'text', fetch: "text,type,slug,cover_url"},
                success: function( data ) {
                  $.map( data.results, function( item ) {
                    searchResults.push( { label : item.snippet_text, value : item.text, type : item.type, slug : item.slug, cover_url : item.cover_url } );
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
