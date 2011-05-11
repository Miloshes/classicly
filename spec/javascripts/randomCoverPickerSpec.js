describe('randomCoverPicker', function(){
	var coverIDs;
	var images;

	describe('assignImage function', function(){
		beforeEach(function(){
			coverIDs = [ { id:10043}, { id:10220}, { id:10295}, { id:10363}];
			images = $("<img class='test'/><img class='test'/><img class='test'/><img class='test'/>");
			$("body").append(images);
			image = $('img.test').first();
		});
		
		afterEach(function(){
			$('img.test').remove();
			$('img.test_2').remove();
		});

		it('should assign the src attribute to image', function(){
			assignImageSource(image, coverIDs);
			expect(image.attr('src')).toNotBe(null);
		});
		
		it('should assign the following format to the src attr: http://spreadsong-book-covers.s3.amazonaws.com/book_id[id]_size2.jpg', function(){
			// WIP use here a regexp
			// id = coverIDs[0].id;
			// 			assignImageSource(image, coverIDs);
			// 			expect(image.attr('src')).toBe("http://spreadsong-book-covers.s3.amazonaws.com/book_id" + id + "_size2.jpg");
		});
		
		it("should return the coverIDs array minus one element", function(){
			previousArraySize = coverIDs.length;
			assignImageSource(image, coverIDs);
			expect(coverIDs.length).toBeLessThan(previousArraySize);
		});
		
		it('should return diferent srcs for different image objects', function(){
			assignImageSource(image, coverIDs);
			expect(coverIDs.length).toBeLessThan(previousArraySize);
			secondImage = $('img.test').eq(1);
			assignImageSource(secondImage, coverIDs);
			expect(secondImage.attr('src')).toNotEqual(image.attr('src'));
		});
		
		it('makes sure that the cover ids are assigned randomly', function(){
			// clone the ids for the test
			coverIDs_2 = [ { id:10043}, { id:10220}, { id:10295}, { id:10363}];
			// clone images
			images_2 = $("<img class='test_2'/><img class='test_2'/><img class='test_2'/><img class='test_2'/>");
			$("body").append(images_2);

			$.each($('img.test'), function(index, image) {
				assignImageSource($(image), coverIDs);
			});
			$.each($('img.test_2'), function(index, image) {
				assignImageSource($(image), coverIDs_2);
			});
			expect($('img.test').first().attr('src')).toNotEqual($('img.test_2').first().attr('src'));
		});
	});
});

