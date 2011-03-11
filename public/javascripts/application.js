// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function(){
	$('.book-description').condense({
		moreSpeed: 'fast',
		lessSpeed: 'fast',
		ellipsis: '',
		moreText: '...more',
		lessText: '...less',
		condensedLength: 350
	});

  // apply buttons to radio inputs
  $('.radio').buttonset();
})


$(document).ready(function(){
  var _paq = _paq || [];
    
  FB.Event.subscribe('edge.create', function(response) {
    _paq.push(["trackLocalConversion"])
  });

  FB.Event.subscribe('edge.delete', function(response) {
  });

  FB.Event.subscribe('comment.create', function(response) {
  });
})

