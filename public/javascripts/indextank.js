// Indextank initialization and jQuery code for autocomplete
var userFormat = function(item) {
  var r = $("<div></div>").addClass("result").append( $("<a></a>").html(item.snippet_text.split(',')[0]));
  return r;
};

$(document).ready(function(){
  $("#indexTankForm").indextank_Ize("http://6wfx.api.indextank.com", "classicly_staging");
  var renderer =  $('#results').indextank_Renderer({format: userFormat});
  $("#term").indextank_Autocomplete().indextank_AjaxSearch( {listeners: renderer}).indextank_InstantSearch();
});


