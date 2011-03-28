  // log homepage visit into mixpanel
  FB.getLoginStatus(function(response) {
    if(response.session)
      mpmetrics.track('Homepage View', {'fb-uid': response.session.uid});
    else
      mpmetrics.track('Homepage View');
  });
