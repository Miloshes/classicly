$ ->
  bookId = $("#book-page").attr('name')
  totalRelatedCovers = $(".related").size()
  audiobook = $('#book-page').hasClass 'audiobook'
  if audiobook
    url = '/related_audiobooks'
  else
    url = '/related_books'
  $.getJSON url + '/' + bookId + '/' + totalRelatedCovers , ( data ) ->
    # get the cover for the current book:
    toTake = data.splice 0, 1
    if audiobook then setCoverForAudiobook( $("#current-book"), toTake ) else setElementCover( $("#current-book"), toTake )
    # assign other covers randomly to related books
    console.log data
    $.each $('.related'), ( index, value ) ->
      totalCovers = data.length
      randCover = Math.floor( Math.random() * totalCovers )
      toTake = data.splice randCover, 1
      if audiobook then setCoverForAudiobook( $( this ), toTake ) else setElementCover( $( this ), toTake )