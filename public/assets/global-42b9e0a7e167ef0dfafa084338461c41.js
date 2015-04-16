function unique( array ){
  var newArray = new Array();

  label:for(var i=0; i < array.length; i++ ){
    for(var j=0; j < newArray.length;j++ ){
      if(newArray[j] == array[i]) 
        continue label;
    }

    newArray[newArray.length] = array[i];
  }

  return newArray;
}


function compressText( text, length ){

  if( text.length > length ){
    text = text.substring(0, ( length - 3) );
    text += '...'
  }

  return text;
}

function ssLess( text,  charCount){
  // get the words that are already bolded
  var words = new Array();

  $( "<div>" + text + "</div>" ).find("b").each(function(index, element){
    words.push( $( this ).text() );
  });

  // nuke html tags
  var nuked = text.replace(/<.*?>/g, '');

  //compress nuked text
  var compressed = compressText( nuked, charCount );

  for( index in words){
    compressed = compressed.replace( words[index], "<b>" + words[index] + "</b>" );
  }

  return compressed;
}
;
