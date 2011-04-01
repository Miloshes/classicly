var _paq = _paq || [];

$(function(){
    // log all clicks in the facebook connect button
  $('#registration a.fb_button').live('click', function(){
    if (RAILS_ENV == "production") {
      //log in performable
      _paq.push(["trackConversion", {
        id: "7SXbBD9Fp588",
        value: null
      }]);
      //log into mixpanel
      mpmetrics.track('FB Login Clicked');
    }
  });

  FB.Event.subscribe('edge.create', function(response) {
    liked_url = response;
    if(RAILS_ENV == 'production'){
      _paq.push(["trackConversion", {
        id: "6Sk7qc8EKYUF",
        value: null
      }]);
      FB.getLoginStatus(function(response) {
        if (response.session) {
          id = response.session.uid
          mpmetrics.track('Facebook Like Book', {'fb_uid': id, 'url': liked_url});
        }else{
          mpmetrics.track('Facebook Like Book', {'url': liked_url});
        }
      });
    }
  });

  FB.Event.subscribe('auth.logout', function(response) {
    $('#nav').html('');
  });

  $(window).load(function(){
    // align small sized covers to the bottom in the related books container
    $('img.cover-art').each(function(){
      if ($(this).height() < 155){
        addToTop = 155 - $(this).height();
        nLeft = $(this).offset().left;
        nTop = $(this).offset().top + addToTop;
        $(this).offset({top: nTop, left:nLeft})
      }
    });
  });

  // apply buttons to radio inputs
  $('.radio').buttonset();

});

  function login(response){
      var query = FB.Data.query('select first_name, hometown_location, pic_small from user where uid={0}',response.session.uid);

      query.wait(function(rows) {
        first_name = rows[0].first_name;
        pic = rows[0].pic_small;
        city = rows[0].hometown_location.city;
        country = rows[0].hometown_location.country;
        showPicInHeader(pic, first_name);
        
        $.ajax({
        type:"POST",
        url:"/logins",
        data: 'country=' + country + '&city=' + city});
      });

      $('#registration a').addClass('displaced');
  }

  function showPicInHeader(pic, userName){
    $('#nav').html('<div id="user_welcome"><img src="' + pic + '"/><span class="name">Welcome back, '+ userName +'!</span></div>');
  }
