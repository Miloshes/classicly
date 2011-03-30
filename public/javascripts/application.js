$(function(){
    // log all clicks in the facebook connect button
  $('#registration a.fb_button').live('click', function(){
    if (RAILS_ENV == 'production') {
        mpmetrics.track('FB Login Clicked');
    }
  });

  FB.Event.subscribe('edge.create', function(respuesta) {
    liked_url = respuesta;
    FB.getLoginStatus(function(response) {
      if (response.session && RAILS_ENV == 'production') {
        id = response.session.uid
        mpmetrics.track('Facebook Like Book', {'fb_uid': id, 'url': liked_url});
      }
    });
  });

  FB.Event.subscribe('auth.logout', function(response) {
    logout();
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
    
    $('.book-description').condense({
		  moreSpeed: 'fast',
		  lessSpeed: 'fast',
		  ellipsis: '',
		  moreText: '...more',
		  lessText: '...less',
		  condensedLength: 350
	  });
  });

  // apply buttons to radio inputs
  $('.radio').buttonset();

});

  function login(response){
      var query = FB.Data.query('select first_name, last_name, pic_small, hometown_location, email from user where uid={0}',response.session.uid);

      query.wait(function(rows) {
        city =  rows[0].hometown_location.city;
        state = rows[0].hometown_location.state;
        country = rows[0].hometown_location.country;
        first_name = rows[0].first_name;
        last_name = rows[0].last_name;
        email = rows[0].email;
        pic_small = rows[0].pic_small;

       showPicInHeader(pic, first_name);

        $.ajax({
        type:"POST",
        url:"/logins",
        data: 'uid=' + response.session.uid + '&first_name=' + first_name  +  '&last_name=' + last_name + 
              '&email=' + email +'&city=' + city + '&state=' + state + '&country=' + country});
      });

      $('#registration a').addClass('displaced');
  }

  function logout(){
    $.ajax({ type:"DELETE", url:"/logins"});
    $('#nav').html('');
  }
  
  function showPicInHeader(pic, userName){
    $('#nav').html('<div id="user_welcome"><img src="' + pic + '"/><span class="name">Welcome back, '+ userName +'!</span></div>');
  }
