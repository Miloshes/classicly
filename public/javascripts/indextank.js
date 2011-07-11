// Indextank initialization and jQuery code for autocomplete

var publicApiUrl = "http://6wfx.api.indextank.com";
var indexName = "classicly_staging";


$(document).ready(function(){
  // let the form be 'indextank-aware'
  $("#indexTankForm").indextank_Ize(publicApiUrl, indexName);
  // let the query box have autocomplete
  $("#term").indextank_Autocomplete();
});
