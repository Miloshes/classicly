$(function(){
  $('.download-link').click(function(){
    return true;
  });
  $(window).load(function(){
    if($('.download-link').attr('name') == 'pdf'){
      $('.download-link').attr('target', '_blank');
    }else{
      window.location = $('.download-link').attr('href');
    }
  });

});
