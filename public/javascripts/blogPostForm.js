$(document).ready(function(){
  // set Markitup plugin for the editor:
  $( '#blog_post_content' ).markItUp( mySettings );
  // autocomplete to pickup covers
  var sourceCallback = function( request, responseCallback ) {
    $.ajax( {
      url: '/autocomplete_books_json',
      dataType: "json",
      data: { term: request.term },
      success: function( data ) {
        responseCallback( $.map( data, function( item ) {
            return {
              label: item.pretty_title,
              value: item.id,
            }
        }));
      }
    });
  };
  
  var selectCallback = function( event, ui ) {
    // send the ajax call to save the book as related to the blog post
    blogPostId = $( 'ul.related-books' ).attr( 'id' );
    $.ajax( {
      url: '/admin/blog_posts/associate_book/',
      data: { id : ui.item.value, blog_post_id: blogPostId }
    });

    $( 'ul.related-books' ).append( '<li class="related">' + 
    '<img src="http://spreadsong-book-covers.s3.amazonaws.com/book_id' + ui.item.value + '_size1.jpg">'+
    '<span class = "close"><a id="' + ui.item.value + '" href="#">X</a></span>' + 
    '<span class="title">' + ui.item.label + '</span><li>' );
    ui.item.value = ''; // clear the value!
    
  };
  
  $( "#covers-autocomplete" ).autocomplete({
    source: sourceCallback,
    minLength: 2,
    select: selectCallback
  });
  
  
  // delete associations
  $( 'ul.related-books li span.close a' ).live('click', function(){
    var link = $( this );
    bookId = link.attr( 'id' );
    blogPostId = $( 'ul.related-books' ).attr( 'id' );
    $.ajax( {
      url: '/admin/blog_posts/associate_book/',
      data: { id : bookId, blog_post_id: blogPostId, delete: true },
      success: function(response){
        link.parents( 'li' ).remove();
      }
    });
    return false;
  });
});