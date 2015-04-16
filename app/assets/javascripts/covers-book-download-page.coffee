$ ->
  bookId = $("#download-confirmation-page").attr('name')
  totalRelatedCovers = $("#download-confirmation-page .related").size()
  $.getJSON '/related_books/' + bookId + '/' + totalRelatedCovers , ( data ) ->
    $.each $('#download-confirmation-page .related'), ( index, value ) ->
      totalCovers = data.length
      randCover = Math.floor( Math.random() * totalCovers )
      toTake = data.splice randCover, 1
      setElementCover( $( this ), toTake )