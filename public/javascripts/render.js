/* todo: first line indent */

/* Breaks chunk of text into pages that fit into div box. */
function Render(book_content){
  /*
   Stores pages information as indexes of starting and ending
   symbols. 
   */
  this.book_content = book_content;
  this.lines_array = book_content.split("\n");
  this.page_boundary = $("#render");
  this.page_container = $("#inner");
  /* where page started */
  this.page_start = 0;
  /* current position in text chunk */
  this.current_postion = 0;
  /* current line in lines array */
  this.current_line = -1;
  /* remaining words in current line */
  this.line_words = [];
  /* array with indexes of a pages */
  this.result = [];
  return this;
}

Render.prototype = {

  /*
   
   cb(page_data) : callback to be triggered when another page
                   is ready.
   page_data     : { page_start: 0, page_end: 103 }
   
   */
  render_book: function(cb){
    var self = this;
    if(this.current_line < this.lines_array.length){
      var page = this.render_page();
      this.result.push(page);
      cb(page);
      setTimeout(function(){
		   self.render_book(cb);
		 }, 0);
    };
  },
  
  render_page: function(){
    this.page_container.empty();
    this.page_start = this.current_postion;
    var page_end, result, word;
    while(this.size_test()){
      page_end = this.current_postion;
      result = this.get_word();
      this.append_word(result.word+' ', result.line_break);
    }
    this.push_word(result.word);
    return {
      page_start: this.page_start,
      page_end: page_end
    };
  },

  /* appends words to the text */
  append_word: function(word, line_break){
    if(!this.page_container.children().is('p')||line_break){
      var p = $('<p/>');
      if(line_break){
	p.addClass('new_paragraph');
      }
      this.page_container.append(p);
    }
    this.page_container.find('p:last').append(word);
  },
  
  /* get next word in text chunk */
  get_word: function(){
    var line_break = false;
    if(this.line_words.length < 1){
      this.current_line += 1;
      this.line_words = this.lines_array[this.current_line].split(/\s/);
      line_break = true;
    }
    var word = this.line_words.shift();
    this.current_postion += word.length + 1;      
    return {word: word, line_break: line_break};
  },

  push_word: function(word){
    this.line_words.unshift(word);
    this.current_postion -= word.length + 1;
  },
  
  /* returns true if inner div is bigger than outer */
  size_test: function(){
    return this.page_boundary.height() > this.page_container.height();
  }
  
};

function push_data(book_id, page, start_character, end_character){
  var data = {
    book_id : book_id,
    action : 'process_render_data',
    render_data : [{
		     page : page,
		     first_line_indent : false,
		     start_character : start_character,
		     end_character : end_character
		   }]
  };
  $.post('/reader_engine_api',
	 {json_data : $.toJSON(data)},
	 function(data){
	   console.log('returned from server:');
	   console.log(data);
	 });
}

$(function(){
    var book_link = '/book/book_6061.txt';
    $.get(book_link, function(data){
	    var r = new Render(data);
	    var page = 1;
	    var book_id = 6061;
	    $("#render_book").click(
	      function(){
		r.render_book(
		  function(page_data){
		    push_data(book_id,
			      page,
			      page_data.page_start,
			      page_data.page_end);
		    $('#pages_done').text(page);
		    page++;
		  });
	      });
	  });
  });