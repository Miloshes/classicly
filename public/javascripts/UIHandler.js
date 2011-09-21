UIHandler = function(){};

UIHandler.prototype = {
  removeSigninMessage: function(){
    html = "<div id='profile-pic'><a href='/library'><img src= 'http://graph.facebook.com/" + this.uid + "/picture?type=square'/></a></div>"
    $( ".top #signin" ).remove();
    $( html ).insertAfter( "#nav" );
  },
  setuid: function(uid){
    this.uid = uid;
  }
}