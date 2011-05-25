$ ->
  # =============================== FILL COLLECTION COVERS
  # let's get covers for the current collection:
  currentCollectionId = $('.featured-books').attr('name').split('_')[1]
  audiobooks = $('.featured-books').hasClass 'audiobooks'
  if audiobooks
    params = { id: currentCollectionId, type: 'audiobook' }
  else
    params = { id: currentCollectionId }
  $.getJSON 'collection_json_books', params,  ( data ) ->
    $.each data, (index, value) ->
      # find current collection element:
      selector = '.featured-books'
      bookData = value.books
      # find every cover holder and fill it with the cover:
      $.each $( selector + ' .cover-here'), ( index, value ) -> # ATTENTION! don't remove the blank space before .cover-here
        totalCovers = bookData.length
        randCover = Math.floor(Math.random() * totalCovers)
        toTake = bookData.splice randCover, 1
        if totalCovers > 0
          if audiobooks then setElementCover( $( this ), toTake ) else setCoverForAudiobook( $( this ), toTake )
        else
          $(this).remove();
  # =============================== FILL COLLECTION'S BOOKS COVERS
  coversForRelatedBooks()