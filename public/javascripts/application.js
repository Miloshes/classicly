// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function(){
  // collapse book descriptions in home page
  $('p.book-description').moreLess({
   speed:'fast',
   truncateIndex: 150 
  });
})


