$(function(){
  $('.download-link').click(function(){
    return true;
  });

  $(window).load(function(){
  	window.location = $('.download-link').attr('href');
  });
  
  FB.Event.subscribe('edge.create', function(response) {
    $.ajax({
      url: '/bingo_experiments/create'
    });
  });
});
