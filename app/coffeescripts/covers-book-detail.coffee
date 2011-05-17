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
    bookId = $("#book-page").attr('name')
    totalRelatedCovers = $(".related").size()
    $.getJSON '/related_books/' + bookId + '/' + totalRelatedCovers , ( data ) ->
      # get the cover for the current book:
      toTake = data.splice 0, 1
      setElementCover $("#current-book"), toTake
      # assign other covers randomly to related books
      $.each $('.related'), ( index, value ) ->
        totalCovers = data.length
        randCover = Math.floor( Math.random() * totalCovers )
        toTake = data.splice randCover, 1
        setElementCover( $( this ), toTake )
    $.getJSON '/random_json_books/3', (data) ->
      $.each $('#right-column .row .cover-here, #right-column .row .cover-with-title-here'), (index, value) ->
        totalCovers = data.length
        randCover = Math.floor(Math.random() * totalCovers)
        toTake = data.splice randCover, 1      
        setElementCover( $( this ), toTake )
    

window.Cover = new Cover()
window.Cover.init()