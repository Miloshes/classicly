  // log homepage visit into mixpanel
  FB.getLoginStatus(function(response) {
    if(response.session)
      mpmetrics.track('homepage-view', {'fb-uid': response.session.uid});
    else
      mpmetrics.track('homepage-view');
  });
