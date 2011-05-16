class Cover
  init: ->
    Cover::initCovers()
    
    # align small sized covers to the bottom in the related books container
    $('img.cover-art').each -> 
      if $(this).height() < 155
        addToTop = 155 - $(this).height()
        nLeft = $(this).offset().left
        nTop = $(this).offset().top + addToTop
        $(this).offset top: nTop, left: nLeft

  initCovers: ->
    $.getJSON '/home_page_books_for_author', (data) ->
      $.each $('.cover-here, .cover-with-title-here'), (index, value) ->
        randCover = Math.floor(Math.random() * totalCovers)
        toTake = data.splice randCover, 1
        totalCovers = data.length
        
        $(this).children('.stable').append '<img src="http://spreadsong-book-covers.s3.amazonaws.com/book_id' + toTake[0].id +'_size3.jpg"/>'
        $(this).wrap('<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">')
        
        if $(this).hasClass 'cover-with-title-here'
          $(this).append '<div class="text" style="display:none"><span class="title">' + toTake[0].pretty_title + '</span><span class="type">Book</span></div>'
        $('.cover-here img, .cover-with-title-here img').bind 'load', ->
          $(this).siblings('.spinner').fadeOut 200, ->
            $(this).parents().siblings('.text').fadeIn 1000
            $(this).siblings('img').fadeIn 1000

window.Cover = new Cover()

# coverURLs = [
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id18847_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id87_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id2133_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id4281_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id14328_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id17776_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id7186_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id264_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id12841_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id9148_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id10_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id23229_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id18744_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id18735_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id13887_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id18195_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id9265_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id20858_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id15791_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id15167_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id1743_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id21336_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id16671_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id119_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id9779_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id18813_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id2930_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id9661_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id1107_size3.jpg'
#   'http://spreadsong-book-covers.s3.amazonaws.com/book_id22360_size3.jpg'
# ]
