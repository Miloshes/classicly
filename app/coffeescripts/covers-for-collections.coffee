$ ->
  collections =  $( ".collection-here, .collection-with-title-here" )
  $.each collections, ( index, value ) ->
    collection = $( this )
    collectionId = collection.attr('name');
    audiobooks = collection.hasClass( 'audiobooks' )
    covers = collection.children( '.cover-here' )
    $.getJSON '/collection_json_books' , { id : collectionId, total_books:covers.size()}, ( data ) ->
      collection.append  '<div class="text"><a href="' + data[0].collection_slug + '"><span class="title">' + data[0].collection_name + '</span></a><span class="type">Collection</span></div>'
      $.each data, (index, value) ->
        # find current collection element:
        bookData = value.books
        # find every cover holder and fill it with the cover:
        $.each covers, ( index, value ) ->
          totalCovers = bookData.length
          randCover = Math.floor( Math.random() * totalCovers )
          toTake = bookData.splice randCover, 1
          if totalCovers > 0
            if audiobooks then setCoverForAudiobook( $( this ), toTake ) else setElementCover( $( this ), toTake )
          else
            $(this).remove();
        