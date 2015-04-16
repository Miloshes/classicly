
function assignImageSource(image, coverIDs){
	randomNumber = Math.floor(Math.random() * coverIDs.length)
	image.attr('src', "http://spreadsong-book-covers.s3.amazonaws.com/book_id" + coverIDs[randomNumber].id + "_size2.jpg");
	coverIDs.splice(randomNumber, 1);
}