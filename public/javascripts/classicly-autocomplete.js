var elementId = "#term";
var apiUrl =  "http://6wfx.api.indextank.com";
var indexName = "classicly_staging";
var source = apiUrl + "/v1/indexes/" + indexName + "/search";
var titles;

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
                data: {start:0, rsLength:5, len:5, q:data.suggestions[0], snippets:'text', fetch: "text", fetch_categories: 'true', fetch_variables: 'true'},
                success: function( data ) {
                  $.map( data.results, function( item ) {
                    titles.push(item.text);
                  });
                  responseCallback( $.each(titles, function( index, value ){
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