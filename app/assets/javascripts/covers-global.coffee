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
  popularCovers = $('#right-column .row .cover-here.popular, #right-column .row .cover-with-title-here.popular')
  if $('#right-column .row').hasClass 'audiobooks'
    url = '/random_json_audiobooks/'
    audiobook = true
  else
    url = '/random_json_books/'
  $.getJSON url + popularCovers.size(), (data) ->
    $.each popularCovers, (index, value) ->
      totalCovers = data.length
      randCover = Math.floor(Math.random() * totalCovers)
      toTake = data.splice randCover, 1
      if audiobook
        setCoverForAudiobook( $( this ),  toTake )
      else
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