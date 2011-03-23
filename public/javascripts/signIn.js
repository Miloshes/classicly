$(function(){

  FB.Event.subscribe('auth.login', function(response) {
    login(response);
  });

});
