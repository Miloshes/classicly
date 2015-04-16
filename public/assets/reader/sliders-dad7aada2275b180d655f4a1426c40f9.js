(function( $ ){


    var methods = {
    init: function(options) {
      /* create markup */
      this
        .append($('<div>').addClass('slider_active'))
        .append($('<div>').addClass('slider_disabled'))
        .append($('<div>').addClass('slider_cursor'))
        .append($('<div>').addClass('clear'));

      options = options || {};
      options = $.extend({
			   onChange : $.noop,
			   live_change : false,
			   default_value: 0
			 }, options);
      this.data('slider.options', options);
      var slider = this;
      var cursor = this.cursor = this.children('.slider_cursor');
      var self = this;
      var max_enabled = options.max_enabled || 1;
      this.data('slider.max_enabled', max_enabled);
      this.slider('enable', max_enabled);
      var mouse_move = {moved: false, amount: 0};
      this.data('slider.mouse_move', mouse_move);

      function getRelative(ev){
        var current_width = ev.pageX - slider.offset().left;
        if(current_width < 0){return 0;};
        if(current_width > slider.width()){return 1;};
        return current_width/slider.width();
      };
      
      function mousemove(ev){
        var amount = getRelative(ev);
        self.slider('_move_with_mouse', amount, options.live_change, false);
        mouse_move = {moved: true, amount: amount};
      }

      cursor.bind('mousedown.slider', function(ev){
          ev.preventDefault();
          mouse_move.moved = true;
          self.data('slider.mouse_move', mouse_move);
          $('html').bind('mousemove.slider', mousemove);
          var html_mouse_up = function(){
              $('html').unbind('mouseup', html_mouse_up);
              $('html').unbind('mousemove', mousemove);
              if(mouse_move.moved){
                self.slider('_move_with_mouse', mouse_move.amount, true, true);
                mouse_move.moved = false;
                self.data('slider.mouse_move', mouse_move);
              }
          };
          $('html').bind('mouseup.slider', html_mouse_up);
      });

      slider.bind('click.slider', function(ev){
          if(!mouse_move.moved){
            var amount = getRelative(ev);
            self.slider('move', amount, true);
          }
          return false;
      });

      return this;
    },
    /* amount should be between 0 and 1 */
    move: function(amount, trigger_callback, end_of_move){
      end_of_move = typeof end_of_move == 'undefined' ? true : end_of_move;
      if(this.data('slider.mouse_move') && this.data('slider.mouse_move').moved){
        return;
      }
      this.slider('_move_with_mouse', amount, trigger_callback, end_of_move);
    },

    /* move cursor even if mouse is moving it */
    _move_with_mouse: function(amount, trigger_callback, end_of_move){
      trigger_callback = trigger_callback || false;
      var max_enabled = this.data('slider.max_enabled');
      if(amount > max_enabled){
        amount = max_enabled;
      }
      if(amount < 0){
        amount = 0;
      }
      var slider = this;
      var cursor = this.children('.slider_cursor');
      cursor.css('left', (amount*slider.width() - cursor.width()/2)+'px');
      this.data('slider.value', amount);
      if(trigger_callback){
        this.data('slider.options').onChange({amount:amount, end_of_move: end_of_move});
      }
    },

    /* amount should be between 0 and 1 */
    enable: function(amount){
      if(amount > 1){
        amount = 1;
      }
      if(amount < 0){
        amount = 0;
      }
      var enabled_bar = this.children('.slider_active');
      var disabled_bar = this.children('.slider_disabled');
      enabled_bar.css('width', amount*100 + '%');
      disabled_bar.css('width', (1-amount)*100 + '%');
      this.data('slider.max_enabled', amount);
      if(this.data('slider.value') > amount){
        this.slider('move',amount);
      }
    },

    destroy: function(){
      this.cursor.unbind('.slider');
      this.unbind('.slider');
      $('html').unbind('.slider');
      /* todo store all data in one object and here remove it */
      this.removeData();
      this.empty();
    }
  };

  $.fn.slider = function( method ) {
    var m = methods[method];
    if(m){
      return m.apply(this,
                     Array.prototype.slice.call( arguments, 1 ));
    } else {
      return methods.init.apply( this, arguments );
    } 
  };

})( jQuery );
