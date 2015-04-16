$ ->
  class Cover
    init: ->
      Cover::initCovers()
    initCovers: ->
      totalBooks = $('.random-book').size()
      $.getJSON '/random_json_books/' + totalBooks, (data) ->
        $.each $('.random-book'), (index, value) ->
          randCover = Math.floor(Math.random() * totalCovers)
          toTake = data.splice randCover, 1
          totalCovers = data.length
          setElementCover( $( this ), toTake )
  window.Cover = new Cover()
  window.Cover.init()