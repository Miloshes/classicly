/*
 todo: two pages on large screens?
 todo: endless scrolling variation?
 todo: use enchansed justify?
 todo: add more error handling. (when page is not loaded)
 */

function Book(id){
  this.id = id;
  this._total_pages = null;
  this._title = null;
  /* cache for already downloaded pages */
  this.page_cache = {};

  return this;
}

Book.prototype = {
  get_page : function(page_num, cb){
    /* check page cache for page */
    if(this.page_cache[page_num]){
      cb(this.page_cache[page_num]);
    }else{
      var self = this;
      var data = {
        action : 'get_page',
        book_id : this.id,
        page_number : page_num
      };
      $.post('/reader_engine_api/query',
             {json_data : $.toJSON(data)},
             'json')
        .success(function(data){
                   if(data.match(/^\s*$/)){
                     cb(null);
                     return;
                   }
                   data = $.parseJSON(data);
                   if(!self._total_pages || !self._title){
                     self._total_pages = data.total_page_count;
                     self._title = data.book_title;
                   }
                   self.page_cache[page_num] = {
                     content : data.content.split("\n"),
                     first_line_indent : data.first_line_indent
                   };
                   cb(self.page_cache[page_num]);
                 })
        .error(function(){
                 cb(null);
               });
    }

  },

  get_total_pages : function(){
    if(!this._total_pages){
      throw "Cannot get page total: load any page first.";
    }
    return this._total_pages;
  },

  get_title : function(){
    if(!this._title){
      throw "Cannot get page title: load any page first.";
    }
    return this._title;    
  }
  
};

function Reader(book){
  this.book = book;
  this.current_page = this._get_page_id_from_url();
  this.init();
  this.draw_page(this.current_page);
  return this;
}

Reader.prototype = {

  turn_page_left : function(){
    if(this.current_page > 1){
      this.draw_page(this.current_page -1);
    }
  },

  turn_page_right : function(){
    if(this.current_page < this.book.get_total_pages()){
      this.draw_page(this.current_page + 1);
    }    
  },

  show_loading : function(){
    $('#reader_box .loading_box').show();
  },

  hide_loading : function(){
    $('#reader_box .loading_box').hide();
  },

  show_error : function(){
    $('#reader_box .error_box').show();
  },
  clear_content : function(){
    $('#reader_box .text_box').empty();
  },

  _set_page_id_to_url : function(num){
    if(typeof history.replaceState === 'function'){
      var new_location =
        window.location.pathname.replace(/\/[0-9]+$/, '/'+num);
      history.replaceState(null, '', new_location);
    }else{
      window.location.hash = num;      
    }

  },

  _get_page_id_from_url : function(){
    var hash = window.location.hash;
    var result;
    if(hash === ""){
      result = location.pathname.match(/\/([0-9]+)$/)[1];
    }else{
      result = hash.slice(1);
    }
    return Number(result);
  },

  draw_page : function(num){
    var self = this;
    var book = this.book;
    this.current_page = num;
    this.show_loading();
    book.get_page(num,
                  function(page_data){
                    var page_content = page_data.content;
                    var first_line_indent = page_data.first_line_indent;
                    self.hide_loading();
                    if(page_content == null){
                      self.show_error();
                      return;
                    }
                    var text_box = $('#reader_box .text_box');
                    self.clear_content();
                    $.each(page_content,
                           function(i,string){
                             var p = $('<p>').text(string);
                             text_box.append(p);
                           });
                    if(!first_line_indent){
                      text_box.find('p:first').addClass('no_indent');
                    }
                    self._set_title(book.get_title());
                    self._slider_move_to_page(num);
                    self._set_page_id_to_url(num);
                    self._prefetch(Number(num) + 1);
                  });
  },
  
  init : function(){
    this.controls = $('.big_navigation .box, .slider_wrap, .header');
    this._controls_on_hover();
    this._init_navigation();
    this._init_slider();
    this._init_shorcuts();
  },

  _init_slider : function(){
    var self = this;
    this.slider = $('#reader_box .navigation .slider');
    this.slider.slider({
                         onChange : function(e){self._slider_on_change(e);},
                         live_change : true
                       });
    this.slider_cursor = $('#reader_box .navigation .slider_cursor');
    var before_scroller_num = $('<div/>').addClass('before_scroller_num');
    this.page_num = $('<div/>').addClass('page_num');
    var after_scroller_num = $('<div/>').addClass('after_scroller_num');
    this.slider_cursor
      .append(before_scroller_num)
      .append(this.page_num)
      .append(after_scroller_num);
  },

  _init_navigation : function(){
    var self = this;

    $('#reader_box .big_navigation.left .box')
      .click(function(){
               self.turn_page_left();
               return false;
             })
      .mousedown(function(){
                   return false;
                 });
    $('#reader_box .big_navigation.right .box')
      .click(function(){
               self.turn_page_right();
               return false;           
             })
      .mousedown(function(){
                   return false;
                 });
  },
  
  _init_shorcuts : function(){
    var self = this;
    $.each(['right', 'space', 'l'], function(){
             shortcut.add(this,function() { self.turn_page_right(); });              
           });
    $.each(['left', 'h'], function(){
             shortcut.add(this,function() { self.turn_page_left(); });       
           });        
  },

  _prefetch : function(page){
    var self = this;
    setTimeout(function(){
                 self.book.get_page(page, $.noop);
               }, 0);
  },

  _slider_move_to_page : function(page){
    var page_length = 1 / this.book.get_total_pages();
    this.slider.slider('move', page_length * (page-1), true, false);
    this._slider_set_page_num(page);
  },
  
  _slider_on_change : function(event){
    if(event.amount == 0 ){
      event.amount = 0.0001;
    }
    var page = Math.ceil(this.book.get_total_pages() * event.amount);
    this._slider_set_page_num(page);
    if(event.end_of_move){
      this.draw_page(page);
    }
  },
  
  _slider_set_page_num : function(num){
    this.page_num.text(num);
  },

  _set_title : function(title){
    $('#reader_box .header').text(title);
  },

  _controls_on_hover : function(){
    var self = this;
    $('body')
      .mousemove(function(){
                   self._flash_controls();
                   return true;
             });
  },


  _flash_controls : function(){
    var self = this;
    this._show_controls();
    if(typeof arguments.callee.timeout_id !== 'undefined'){
      clearTimeout(arguments.callee.timeout_id);
    }
    arguments.callee.timeout_id = 
      setTimeout(function(){
                   self._hide_controls();
                 },2000);
  },

  _hide_controls : function(){
    this.controls.fadeOut();
  },

  _show_controls : function(){
    this.controls.fadeIn();
  }
};