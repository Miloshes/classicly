window.Covers =
  init: ->
    Covers.initCovers()

    # align small sized covers to the bottom in the related books container
    $('img.cover-art').each -> 
      if $(this).height() < 155
        addToTop = 155 - $(this).height()
        nLeft = $(this).offset().left
        nTop = $(this).offset().top + addToTop
        $(this).offset top: nTop, left: nLeft

  initCovers: ->

    totalCovers = coverURLs.length
    $.each $('.cover-here'), (index, value) ->
      randCover = Math.floor(Math.random() * totalCovers)
      toTake = coverURLs.splice randCover, 1
      totalCovers = coverURLs.length

      $(this).append('<img src="'+toTake+'"/>')

      $('.cover-here img').bind 'load', ->
        $(this).siblings('.loader').fadeOut 250, ->
          $(this).siblings('img').fadeIn 1000

  initAuthors: ->

  initCollections: ->

coverURLs = [
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id18847_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id87_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id2133_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id4281_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id14328_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id17776_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id7186_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id264_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id12841_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id9148_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id10_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id23229_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id18744_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id18735_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id17542_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id13887_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id18195_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id9265_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id20858_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id15791_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id15167_size3.jpg'
  'http://spreadsong-book-covers.s3.amazonaws.com/book_id15167_size3.jpg'
]
