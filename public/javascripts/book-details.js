$(function(){
  // stripe reviews
  $('ul.reviews li:nth-child(odd)').addClass('striped');
  $('div.rating-cancel').remove();

  // validation for empty review form
  $('input#review_submit').click(function(){
    errorTextArea = ($('textarea#review_content').val().length == 0);
    errorRating = ($("input[name='review[rating]']:checked").get(0) == undefined);
    
    $('#errorExplanation').remove();
    if( errorTextArea || errorRating ){
      $("<div id='errorExplanation'>"
       + "<h2>Oops! We had problems saving this review</h2>" 
       + "<ul> "+ errorsOnReview(errorTextArea, errorRating) + "</ul></div>").insertBefore("div.ratings");
       $('input#review_submit').addClass('displaced');
    }else{
      $(this).parent().submit();
    }
    return false;
  });

  function errorsOnReview(errorTextArea, errorRating){
    errors = ''
    if (errorTextArea)
      errors += "<li>Review content can't be blank</li>"
    if (errorRating)
      errors += "<li> Please assign a rating</li>"
    return errors;
  }
  
  // login to facebook from <Write a review> link
  $('#title-right a').click(function(){
    FB.getLoginStatus(function(response) {
      if(!(response.session)) {
        $('a.fb_button').click();
      }
    });
    return false;
  });
  
  // if the user has signed in and the form is not shown yet , show it
  FB.Event.subscribe('auth.login', function(response) {
    loginInBookDetails(response);
  });

  // logout the user when he/she has logged out directly from facebook
  FB.Event.subscribe('auth.logout', function(response) {
    if($('#form_box') != undefined )
      $('#form_box').remove();
  });
});

function loginInBookDetails(response){
  var query = FB.Data.query('select first_name, last_name, pic_small, hometown_location, email from user where uid={0}',response.session.uid);

      query.wait(function(rows) {
        country = rows[0].hometown_location.country;
        city = rows[0].hometown_location.city;
        first_name = rows[0].first_name;
        pic = rows[0].pic_small;

        showPicInHeader(pic, first_name);
        $.ajax({
        type: "POST",
        url: "/logins",
        data: 'country=' + country +'&city=' + city,
              success: function () {
                showReviewForm();
                $('#registration a').addClass('displaced');
              }
       });
      });
}

function showReviewForm(){
  if($('#form_box').get(0) == undefined){
      id = $('#reviews').data('book_id')
      $.ajax({
        type:"GET",
        url:"/books/" + id + "/show_review_form"
      });
    }
}
