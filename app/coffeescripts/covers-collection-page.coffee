$ ->
  # align small sized covers to the bottom in the related books container
  $('img.cover-art').each -> 
    if $(this).height() < 155
      addToTop = 155 - $(this).height()
      nLeft = $(this).offset().left
      nTop = $(this).offset().top + addToTop
      $(this).offset top: nTop, left: nLeft

  # get all collection's ids:
  allIds = $('li.collection').map ->
    $(this).attr('id').split('_')[1]
  allIds = allIds.get()
  # create a single string:
  data = $(allIds).get().join(',')
  
  # request AJAX sending all collection ids
  $.getJSON 'json_books_for_authors_collection', {id : data },  ( data ) ->
    $.each data, (index, value) ->
      # find collection element:
      selector = 'li.collection#collection_' + value.collection_id
      bookData = value.books
      # find every cover holder and fill it with the cover:
      $.each $( selector + ' .cover-here'), ( index, value ) -> # ATTENTION! don't remove the blank space before .cover-here
        totalCovers = bookData.length
        randCover = Math.floor(Math.random() * totalCovers)
        toTake = bookData.splice randCover, 1
        if totalCovers > 0
          setElementCover( $( this ), toTake )
        else
          $(this).remove();

  #now lets get the featured collection:
  featuredCollectionId = $('#featured-collection').attr('name').split('_')[1]
  $.getJSON 'json_books_for_authors_collection', {id : featuredCollectionId },  ( data ) ->
    $.each data, (index, value) ->
      # find featured collection element:
      selector = '#featured-collection'
      bookData = value.books
      # find every cover holder and fill it with the cover:
      $.each $( selector + ' .cover-here'), ( index, value ) -> # ATTENTION! don't remove the blank space before .cover-here
        totalCovers = bookData.length
        randCover = Math.floor(Math.random() * totalCovers)
        toTake = bookData.splice randCover, 1
        if totalCovers > 0
          setElementCover( $( this ), toTake )
        else
          $(this).remove();

  # finally, fill up the popular covers
  totalPopularCovers = $('#right-column .row .cover-here, #right-column .row .cover-with-title-here').size()
  $.getJSON '/random_json_books/' + totalPopularCovers, (data) ->
    $.each $('#right-column .row .cover-here, #right-column .row .cover-with-title-here'), (index, value) ->
      totalCovers = data.length
      randCover = Math.floor(Math.random() * totalCovers)
      toTake = data.splice randCover, 1      
      setElementCover( $( this ), toTake )