$ ->
  # align small sized covers to the bottom in the related books container
  $('img.cover-art').each -> 
    if $(this).height() < 155
      addToTop = 155 - $(this).height()
      nLeft = $(this).offset().left
      nTop = $(this).offset().top + addToTop
      $(this).offset top: nTop, left: nLeft
  # =============================== FILL POPULAR BOOKS COVERS:
  # fill up the popular book covers
  totalPopularCovers = $('#right-column .row .cover-here, #right-column .row .cover-with-title-here').size()
  $.getJSON '/random_json_books/' + totalPopularCovers, (data) ->
    $.each $('#right-column .row .cover-here, #right-column .row .cover-with-title-here'), (index, value) ->
      totalCovers = data.length
      randCover = Math.floor(Math.random() * totalCovers)
      toTake = data.splice randCover, 1      
      setElementCover( $( this ), toTake )
  #=============================== FILL RANDOM BOOK COVERS (Main Page) IF EXIST:
  randomBooks = $('.random-book')
  totalBooks = randomBooks.size() if randomBooks.get(0)
  if randomBooks.get(0)
    $.getJSON '/random_json_books/' + totalBooks, (data) ->
      $.each $('.random-book'), (index, value) ->
        randCover = Math.floor(Math.random() * totalCovers)
        toTake = data.splice randCover, 1
        totalCovers = data.length
        setElementCover( $( this ), toTake )
  # ============================= FILL RANDOM AUDIOBOOK COVERS IF DEFINED
  randomAudiobooks = $('.random-audiobook')
  totalAudiobooks = randomAudiobooks.size() if randomAudiobooks.get(0)
  if randomAudiobooks.get(0)
    $.getJSON '/random_json_audiobooks/' + totalAudiobooks, (data) ->
      $.each $('.random-audiobook'), (index, value) ->
        randCover = Math.floor(Math.random() * totalCovers)
        toTake = data.splice randCover, 1
        totalCovers = data.length
        window.setCoverForAudiobook( $( this ), toTake)