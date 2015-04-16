UIHandler = function(){};

UIHandler.prototype = {
  getAutocompleteHeight: function(){
    return $('ul.ui-autocomplete').height();
  },
  
  removeSigninMessage: function(){
    html = "<div id='profile-pic'><a href='/library'><img src= 'http://graph.facebook.com/" + this.uid + "/picture?type=square'/></a></div>"
    $( ".top #signin" ).remove();
    $( html ).insertAfter( "#nav" );
  },
  setuid: function(uid){
    this.uid = uid;
  },
  
  slideDownContentContainer : function(){
    var pixels = this.getAutocompleteHeight() + 10; // 10 px margin
    $('#content').css('margin-top', pixels + 'px');
  },
  
  slideUpContentContainer : function(){
    $('#content').css('margin-top', '0px');
  }
}
;
