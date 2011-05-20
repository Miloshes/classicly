$ ->
  class Cover
    init: ->
      Cover::initCovers()

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

  window.Cover = new Cover()
  window.Cover.init()