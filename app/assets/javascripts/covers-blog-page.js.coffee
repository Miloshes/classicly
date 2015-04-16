$ ->
  # fetch found books ids
  domElements = $('.related .book-cover')
  # get all collection's ids:
  allIds = domElements.map ->
    $(this).attr('id').split('_')[1]
  allIds = unique allIds.get()
  # create a single string:
  data = $(allIds).get().join(',')
  $.getJSON '/json_books/', {id: data}, (data) ->
    $.each data, ( index, value ) ->
      id = value.attrs.id
      selector = '.related .book-cover#book_' + id + ' .cover-here'
      toTake = [value.attrs]
      setElementCover( $( selector ), toTake )