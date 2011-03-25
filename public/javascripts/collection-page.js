$(function(){

  // if the user has signed in and the form is not shown yet , show it
  FB.Event.subscribe('auth.login', function(response) {
    login(response);
  });

});
