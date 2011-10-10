Function.prototype.bind =  function( name, fn){
  this.prototype[name] = fn;
};

var LoginsController = function(uiHandler){
  this.uiHandler = uiHandler;
};

LoginsController.prototype = {

  dropLoginDrawer : function( fixedDrawer ){
    var drawer = $("#fb_connect_notification");

    if( fixedDrawer )
      drawer.addClass( "fixed" );
    else
      drawer.removeClass( "fixed" );

    if( this.userLoggedIn() )
      return false;
    else
      if ( drawer.is( ":hidden" ) )
        drawer.slideDown( "slow" );

  },

  hideLoginDrawer: function(){
    var drawer = $("#fb_connect_notification");
    if ( drawer.is( ":visible" ) )
      drawer.slideUp( "slow" );
  },

  logIn : function(){
    var self = this;

    FB.login( function( response ){
      if( response.session ){
        self.uiHandler.setuid( response.session.uid );

        $.ajax({
          type: "POST",
          url: "/logins",
          dataType: "json",
          success: function( data ){
            self.pushToKissmetrics( data );
            if( self.afterLoggedIn != undefined )
              self.afterLoggedIn();

            self.hideLoginDrawer();
            self.uiHandler.removeSigninMessage();
          }
        });
      }
    }, { perms:'email'});
  },

  pushToKissmetrics: function( data ){
    if( _kmq == undefined){
      console.log( "Kissmetrics is undefined" );
      return false
    }

    if( data.is_new_login == false )
      _kmq.push(["record", "User Signed In"]);
    else
      _kmq.push(["record", "User Signed Up"]);
  },
  
  userLoggedIn: function(){

    var logged = false;

    FB.getLoginStatus( function( response ) {
      if (response.status == 'connected')
        logged = true;
    });
    return logged;
  }
}
