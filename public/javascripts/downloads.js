$(function(){
  $('.download-link').click(function(){
    return true;
  });

  $(window).load(function(){
  	window.location = $('.download-link').attr('href');
  });
});
