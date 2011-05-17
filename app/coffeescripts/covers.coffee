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
    totalBooks = $('.cover-here, .cover-with-title-here').size() + 3
    $.getJSON '/random_json_books/' + totalBooks, (data) ->
      $.each $('.cover-here, .cover-with-title-here'), (index, value) ->
        randCover = Math.floor(Math.random() * totalCovers)
        toTake = data.splice randCover, 1
        totalCovers = data.length
        setElementCover( $( this ), toTake )

window.Cover = new Cover()
window.Cover.init()

setElementCover = (element, toTake) ->
  element.children('.stable').append '<img src="http://spreadsong-book-covers.s3.amazonaws.com/book_id' + toTake[0].id +'_size3.jpg"/>'
  element.wrap('<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">')
  
  if element.hasClass 'cover-with-title-here'
    element.append '<div class="text" style="display:none"><span class="title">' + toTake[0].pretty_title + '</span><span class="type">Book</span></div>'
  $('.cover-here img, .cover-with-title-here img').bind 'load', ->
    $( this ).siblings('.spinner').fadeOut 200, ->
      $( this ).parents().siblings('.text').fadeIn 1000
      $( this ).siblings('img').fadeIn 1000