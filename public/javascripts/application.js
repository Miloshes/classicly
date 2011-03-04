// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function(){
  docWidth = parseInt($('.wrapper').width());
  imgWidth = parseInt($('#apple-store-banner img').width());
  lft = docWidth - imgWidth;
  $('#apple-store-banner img').css('left', lft + 'px');

	$('div.book-description').condense({
		moreSpeed: 'fast',
		lessSpeed: 'fast',
		ellipsis: '',
		moreText: '(…more)',
		lessText: '(less)',
		condensedLength: 350
	});

  // apply buttons to radio inputs
  $('.radio').buttonset();
})


