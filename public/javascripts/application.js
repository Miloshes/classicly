// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function(){
	$('div.book-description').truncate({max_length: 300});

  // apply buttons to radio inputs
  $('.radio').buttonset();
})


