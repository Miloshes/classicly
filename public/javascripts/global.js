function unique( arrayName ){
  var newArray=new Array();
  label:for(var i=0; i<arrayName.length;i++ ){  
  for(var j=0; j<newArray.length;j++ ){
    if(newArray[j]==arrayName[i]) 
      continue label;
    }
    newArray[newArray.length] = arrayName[i];
  }
  return newArray;
}
