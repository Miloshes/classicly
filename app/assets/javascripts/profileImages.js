$(function(){
  $('.add-profile-pics').each(function(i,e){
    if($(this).hasClass('three'))
      picsToShow = 3;
    else
      picsToShow = randomNumberOfPics();
    addProfilePics($(this), picsToShow)
  })
});

function randomNumberOfPics(){
  var randomNumber = Math.floor(Math.random() * 9);
  return (randomNumber == 0)? 3: randomNumber;
}

function addProfilePics(container, quantity){
  numOfPics = 50;
  for (i=1; i<= quantity; i++){
    picNum = Math.floor(Math.random()* (numOfPics+1));
    container.append('<img src="/images/pics/pic-'+ picNum + '.jpg" />');
  }
}
