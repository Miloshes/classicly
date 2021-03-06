/* todo: first line indent */

/* Breaks chunk of text into pages that fit into div box. */

function Render(book_content){
  /*
   Stores pages information as indexes of starting and ending
   symbols.
   */
  this.book_content = book_content;
  this.lines_array = split_text_into_lines(book_content);
  this.page_boundary = $("#reader_box .text_box");
  this.page_container = $("#inner");
  this.book_done_hook = $.noop;
  /* where page started */
  this.page_start = 0;
  /* current position in text chunk */
  this.current_position = 0;
  /* current line in lines array */
  this.current_line = -1;
  /* remaining words in current line */
  this.line_words = [];
  /* buffer for pushed word */
  this.last_word = {
    pushed : false,
    line_break : false,
    word : ""    
  };
  /* array with indexes of a pages */
  this.result = [];
  return this;
}

Render.prototype = {

  render_book: function(cb){
    var self = this;
    if(this.current_line < this.lines_array.length){
      var page = this.render_page();
      page.page_num = this.result.length + 1;
      this.result.push(page);
      cb(page);
      setTimeout(function(){
                   self.render_book(cb);
                 }, 0);
    }else{
      this.book_done_hook();
    };
  },
  
  render_page: function(){
    this.page_container.empty();
    this.page_start = this.current_position;
    var page_end, result, word, first_line_indent;

    first_line_indent = this.get_word().line_break;
    this.unshift_last_word();
      
    while(this.size_test()){
      page_end = this.current_position -1;
      result = this.get_word();
      if(result === null){
        break;
      }
      this.append_word(result.word+' ', result.line_break);
    }
    this.unshift_last_word();
    
    return {
      page_start: this.page_start,
      page_end: page_end,
      first_line_indent : first_line_indent
    };
  },

  /* appends words to the text */
  append_word: function(word, line_break){
    var first_paragraph = !this.page_container.children().is('p');
    if( first_paragraph || line_break){
      var p = $('<p/>');
      if(first_paragraph && !line_break){
        p.addClass('no_indent');
      }
      this.page_container.append(p);
    }
    this.page_container.find('p:last').append(word);
  },
  
  /* get next word in text chunk */
  get_word: function(){
    var line_break = false;

    if(this.last_word.pushed){
      this.last_word.pushed = false;
      this.current_position += this.last_word.word.length + 1;      
      return this.last_word;
    }
    
    if(this.line_words.length < 1){
      this.current_line += 1;
      if(this.current_line >= this.lines_array.length){
        return null;
      }
      this.line_words = this.lines_array[this.current_line].split(/\s/);
      line_break = true;
    }
    var word = this.line_words.shift();
    this.current_position += word.length + 1;
    this.last_word.word = word;
    this.last_word.line_break = line_break;
    return {word: word, line_break: line_break};
  },

  unshift_last_word: function(){
    this.current_position -= this.last_word.word.length + 1;
    this.last_word.pushed = true;
  },
  
  /* returns true if inner div is bigger than outer */
  size_test: function(){
    return this.page_boundary.height() > this.page_container.height();
  }
  
};

var book_data = {
  action : 'process_render_data',
  render_data : []
};
var timer_id, requests_in_process = 0, book_done = false;

function send_request(){
  requests_in_process++;
  $.post('/reader_engine_api',
         {json_data : $.toJSON(book_data)},
         function(data){
           requests_in_process--;
           if(book_done && requests_in_process < 1){
             $('#rendering_status').text('Rendering status: finished with the book.');
           }
         });
  book_data.render_data = [];
}

function push_data(book_id, page_data){
  clearTimeout(timer_id);
  
  var page = {
    page : page_data.page_num,
    first_line_indent : page_data.first_line_indent,
    first_character : page_data.page_start,
    last_character : page_data.page_end
  };
  
  if(book_data.book_id === undefined){
    book_data.book_id = book_id;
  }

  if(book_data.book_id !== book_id ||
     book_data.render_data.length > 99 ){
       send_request();
     }

  book_data.render_data.push(page);
  timer_id = setTimeout(send_request, 500);
}

function get_book_data(book_id, cb){
  var data = {
    book_id : book_id,
    action : 'get_book'
  };
  $.post('/reader_engine_api/query',
         {json_data : $.toJSON(data)},
         function(data){
           cb(data);
         });  

}

function split_text_into_lines(text) {
	var line_ending = '';

	if (text.indexOf("\r") != -1)
	{
		line_ending = "\r";
	} 
	else
	{
		line_ending = "\n";
	}
	
	return text.split(line_ending);
}

$(function(){
    var page = 0;
    $("#render_book").click(
      function(){
        get_book_data(id, function(data){
                        var r = new Render(data);
                        r.book_done_hook = function(){
                          book_done = true;
                        };
                        r.render_book(
                          function(page_data){
                            page++;
                            push_data(id, page_data);
                          });
                      });
        
      });
  });
