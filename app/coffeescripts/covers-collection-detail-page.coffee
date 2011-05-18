$ ->
  # align small sized covers to the bottom in the related books container
  $('img.cover-art').each -> 
    if $(this).height() < 155
      addToTop = 155 - $(this).height()
      nLeft = $(this).offset().left
      nTop = $(this).offset().top + addToTop
      $(this).offset top: nTop, left: nLeft
  # =============================== FILL COLLECTION COVERS
  # let's get covers for the current collection
  # now lets get the featured collection:
  currentCollectionId = $('.featured-books').attr('name').split('_')[1]
  console.log currentCollectionId
  $.getJSON 'json_books_for_authors_collection', {id : currentCollectionId },  ( data ) ->
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
          setElementCover( $( this ), toTake )
        else
          $(this).remove();
  # =============================== FILL POPULAR BOOKS COVERS
  # fill up the popular book covers
  totalPopularCovers = $('#right-column .row .cover-here, #right-column .row .cover-with-title-here').size()
  $.getJSON '/random_json_books/' + totalPopularCovers, (data) ->
    $.each $('#right-column .row .cover-here, #right-column .row .cover-with-title-here'), (index, value) ->
      totalCovers = data.length
      randCover = Math.floor(Math.random() * totalCovers)
      toTake = data.splice randCover, 1      
      setElementCover( $( this ), toTake )

  # =============================== FILL COLLECTION'S BOOKS COVERS
  # get all books's ids:
  allIds = $('ul.book-list li').map ->
    $(this).attr('id').split('_')[1]
  allIds = allIds.get()
  # create a single string:
  data = $(allIds).get().join(',')
  # request AJAX sending all collection ids
  $.getJSON 'json_books', {id : data },  ( data ) ->
    $.each data, (index, value) ->
      # find book element:
      selector = 'ul.book-list li#book_' + value.attrs.id
      bookData = [value.attrs]
      # set the cover for this book
      setElementCover( $( selector + ' .cover-here'), bookData )