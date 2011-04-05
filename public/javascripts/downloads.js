
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
  
  $('#download-facebook-post.conversion-button.kiss.green.large.kiss').click(function(){
    FB.getLoginStatus(function(response) {
      if (response.session) {
        downloadPagePublishToFacebook();
      } else {
        FB.login(function(response) {
          if (response.session) {
            login(response);
            // show dialog with feed
            downloadPagePublishToFacebook();
          }
        });
      }
    });
   return false;
  });
});

function downloadPagePublishToFacebook(){
  FB.ui(
   {
     appId: $("meta[property='fb:app_id']").attr('content'),
     method: 'feed',
     link: $("meta[property='og:url']").attr('content'),
     picture: $("meta[property='og:image']").attr('content'),
     caption: $("meta[property='og:title']").attr('content'),
     description: $("meta[property='og:description']").attr('content'),
     message: "I am reading " + $("meta[property='og:title']").attr('content') + " at Classicly.com. Here is a free copy for yourself."
   },
   function(response) {
     if (response && response.post_id && RAILS_ENV == 'production') {
       _paq.push(["trackConversion", {
          id: "8V8KUH0UQ4LD",
          value: null
       }]);
     }
   }
 );
}
