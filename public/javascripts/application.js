// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function(){
	$('div.book-description').condense({
		moreSpeed: 'fast',
		lessSpeed: 'fast',
		ellipsis: '',
		moreText: '(…more)',
		lessText: '(less)',
		condensedLength: 250
	});

  // apply buttons to radio inputs
  $('.radio').buttonset();
})


