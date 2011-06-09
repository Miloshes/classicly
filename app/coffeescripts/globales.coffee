# all functions in this file are bound to the Window object to make em global.
$ ->
  window.compressText = (text, threshold) ->
    return text if text.length < threshold
    newText = text.substring 0, (threshold - 2)
    return newText + '...'
    
  window.setElementCover = (element, toTake) ->
      element.children( '.stable' ).append '<img src="http://spreadsong-book-covers.s3.amazonaws.com/book_id' + toTake[0].id + '_size3.jpg"/>'
      element.wrap '<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">'
      if element.hasClass( 'cover-with-title-here' )
        threshold = if element.hasClass 'small' or element.hasClass 'tiny' then 40 else 61
        element.append '<div class="text" style="display:none"><span class="title">' + compressText(toTake[0].pretty_title, threshold) + '</span><span class="type">Book</span></div>'
      $( '.cover-here img, .cover-with-title-here img' ).bind 'load', ->
        $(this).siblings( '.spinner' ).fadeOut 200, ->
          $(this).parents().siblings('.text').fadeIn(1000)
          $(this).siblings('img').fadeIn(1000)
          
  window.setCoverForAudiobook = (element, toTake) ->
    element.children('.stable').append '<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline"><img src="http://spreadsong-audiobook-covers.s3.amazonaws.com/audiobook_id' + toTake[0].id + '_size3.jpg"/></a>'
    #element.wrap '<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">'
    if element.hasClass( 'cover-with-title-here' )
      threshold = if element.hasClass 'small' or element.hasClass 'tiny' then 40 else 61
      element.append '<div class="text" style="display:none"><span class="title">' + compressText(toTake[0].pretty_title, threshold) + '</span><span class="type">Audiobook</span></div>'
    $( '.cover-here img, .cover-with-title-here img' ).bind 'load', ->
      $( this ).parents('a').siblings('.spinner').fadeOut 200, ->
        $(this).parents().siblings('.text').fadeIn(1000)
        $(this).siblings('a').children('img').fadeIn(1000)
  
  window.coversForRelatedBooks = () ->
    allIds = $( 'ul.book-list li' ).map ->
      return $(this).attr('id').split('_')[1]
    allIds = allIds.get()
    #determine if we are going to fetch audiobooks or books
    audiobooks = $( 'ul.book-list' ).hasClass 'audiobooks'
    url = if audiobooks then 'json_audiobooks' else 'json_books'
    #create a single string:
    data = $(allIds).get().join ','
    $.getJSON url, {id: data}, (data) ->
      $.each data, (index, value) -> 
        #find book element:
        bookData = [value.attrs];
        str = if audiobooks then 'ul.book-list li#audiobook_' else ' ul.book-list li#book_'
        selector = str + value.attrs.id + ' .cover-here'
        #set the cover for this book
        if audiobooks then setCoverForAudiobook( $( selector ), bookData ) else setElementCover( $( selector ), bookData )