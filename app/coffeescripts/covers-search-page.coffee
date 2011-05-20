$ ->
  # fetch covers for found books
  domElements = $('ul.book-list li')
  # get all collection's ids:
  allIds = domElements.map ->
    $(this).attr('id').split('_')[1]
  allIds = allIds.get()
  # create a single string:
  data = $(allIds).get().join(',')
  totalCovers = domElements.size()
  
  $.getJSON '/json_books/', {id: data}, (data) ->
    $.each data, ( index, value ) ->
      id = value.attrs.id
      selector = 'ul.book-list li#book_' + id + ' .cover-here'
      toTake = [value.attrs]
      setElementCover( $( selector ), toTake )
      