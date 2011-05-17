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