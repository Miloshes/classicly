var elementId = "#term";
var apiUrl =  "http://classicly.api.houndsleuth.com";
var indexName = "ClassiclyAutocomplete";
var source = apiUrl + "/v1/indexes/" + indexName + "/search";
var searchResults;
var uiHandler = new UIHandler();

/* this allows us to pass in HTML tags to autocomplete. Without this, they get escaped */
$['ui']['autocomplete'].prototype['_renderItem'] = function(ul, item) {
  var html;

  if ( item.type == "book" || item.type == "audiobook") {
    html = '<div class="with-cover"><img src="' + item.cover_url + '" class="micro-cover"><span class="text">' + ssLess(item.label, 40)
      + '<span class="type">' + item.type + '</span></span></div>';
  }
  else if (item.type == "collection") {
    html = item.label + '<span class="type">' + item.type + '</span>';
  }
  else{
   html = item.label;
  }

  return $("<li></li>").data("item.autocomplete", item).append($("<a></a>").html(html)).appendTo(ul);
};

google.setOnLoadCallback(function() {
  $(function() {
    var sourceCallback = function(request, responseCallback) {
      searchResults = [];
      $.ajax({
        url: apiUrl + "/v1/indexes/" + indexName + "/autocomplete",
        dataType: "jsonp",
        data: {query: request.term, field: 'text'},
        success: function(data) {
          if (data.suggestions.length == 0) {
            data.suggestions[0] = data.query
          } 
          $.ajax({
            url: source,
            dataType: "jsonp",
            data: {len: 10, q: "(" + data.suggestions[0] + ") OR full:"  + data.suggestions[0].replace(" ", "") + "^100000", snippet: 'text', fetch: "text,type,slug,cover_url"},
            success: function(data) {
              $.map(data.results, function(item) {
                searchResults.push({label: item.snippet_text, value: item.text, type: item.type, slug: item.slug, cover_url: item.cover_url});
              });
              // finally add the searc for 'xyz' list item:
             searchResults.push({label: "search <b>" + request.term + "</b>", value: request.term});
              responseCallback($.each(searchResults, function(index, result) {
                return {label: result.label, value: result.value}
              })); 
            }
          });
        }
      });
    };

    var selectCallback = function( event, ui ) {
      event.target.value = ui.item.value;
      if( ui.item.slug != undefined )
        window.location = "http://www.classicly.com" + ui.item.slug;
      else
        $(event.target.form).submit(); //wrap form into a jQuery object, so submit honors onsubmit.
    }

    $( elementId ).autocomplete( {
      source: sourceCallback,
      delay: 500,
      select: selectCallback,
      open: function(event, ui) {
        uiHandler.slideDownContentContainer();
      },
      close: function(event, ui) {
        uiHandler.slideUpContentContainer();
      }
    });
  }); // $ fun
}); // g callback