$(function(){
  var _paq = _paq || [];
});


function Global(){
  this.init = function(){
    Global.installObservers();
    Cover.init()

    // apply buttons to radio inputs
    $('.radio').buttonset();
    // remove image and name when signed out
    FB.Event.subscribe('auth.logout', function(response) {
      $('#nav').html('');
    });
    // ---------------
    // LOG CODE BEGINS
    // ---------------

    // log all clicks in the facebook connect button
    $('#registration a.fb_button').live('click', function(){
      if (RAILS_ENV == "production") {
        //log in performable
        _paq.push(["trackConversion", {
          id: "7SXbBD9Fp588",
          value: null
        }]);
        //log into mixpanel
        mpmetrics.track('FB Login Clicked');
      }
    });

    FB.Event.subscribe('edge.create', function(response) {
      liked_url = response;
      if(RAILS_ENV == 'production'){
        _paq.push(["trackConversion", {
          id: "6Sk7qc8EKYUF",
          value: null
        }]);
        FB.getLoginStatus(function(response) {
          if (response.session) {
            id = response.session.uid
            mpmetrics.track('Facebook Like Book', {'fb_uid': id, 'url': liked_url});
          }else{
            mpmetrics.track('Facebook Like Book', {'url': liked_url});
          }
        });
      }
    });
  
    $('#apple-store-banner').click(function(){
      if(RAILS_ENV == "production"){
        mpmetrics.track('AppleStore Banner Clicked');
      }
    });

    function login(response){
        var query = FB.Data.query('select first_name, hometown_location, pic_small from user where uid={0}',response.session.uid);

        query.wait(function(rows) {
          first_name = rows[0].first_name;
          pic = rows[0].pic_small;
          if(rows[0].hometown_location == null){
            city = "";
            country = "";
          }else{
            city = rows[0].hometown_location.city;
            country = rows[0].hometown_location.country;
          }

          showPicInHeader(pic, first_name);

          $.ajax({
            type:"POST",
            url:"/logins",
            dataType: "json",
            data: 'country=' + country + '&city=' + city,
            success: function(data){
              if(data.new_login && RAILS_ENV == "production"){
                _paq.push(["trackConversion", {
                  id: "3F6mY45twfux",
                  value: null
                }]);
              }
            }
          });
        });
        $('#registration a').addClass('displaced');
    }

  function showPicInHeader(pic, userName){
    $('#nav').html('<div id="user_welcome"><img src="' + pic + '"/><span class="name">Welcome back, '+ userName +'!</span></div>');
    }
  }

  this.installObservers = function(){
  }
}
Global = new Global();

/**
 * Unobtrusive scripting adapter for jQuery
 *
 * Requires jQuery 1.4.3 or later.
 * https://github.com/rails/jquery-ujs
 */

(function($) {
	// Make sure that every Ajax request sends the CSRF token
	function CSRFProtection(xhr) {
		var token = $('meta[name="csrf-token"]').attr('content');
		if (token) xhr.setRequestHeader('X-CSRF-Token', token);
	}
	if ('ajaxPrefilter' in $) $.ajaxPrefilter(function(options, originalOptions, xhr){ CSRFProtection(xhr) });
	else $(document).ajaxSend(function(e, xhr){ CSRFProtection(xhr) });

	// Triggers an event on an element and returns the event result
	function fire(obj, name, data) {
		var event = new $.Event(name);
		obj.trigger(event, data);
		return event.result !== false;
	}

	// Submits "remote" forms and links with ajax
	function handleRemote(element) {
		var method, url, data,
			dataType = element.attr('data-type') || ($.ajaxSettings && $.ajaxSettings.dataType);

		if (element.is('form')) {
			method = element.attr('method');
			url = element.attr('action');
			data = element.serializeArray();
			// memoized value from clicked submit button
			var button = element.data('ujs:submit-button');
			if (button) {
				data.push(button);
				element.data('ujs:submit-button', null);
			}
		} else {
			method = element.attr('data-method');
			url = element.attr('href');
			data = null;
		}

		$.ajax({
			url: url, type: method || 'GET', data: data, dataType: dataType,
			// stopping the "ajax:beforeSend" event will cancel the ajax request
			beforeSend: function(xhr, settings) {
				if (settings.dataType === undefined) {
					xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
				}
				return fire(element, 'ajax:beforeSend', [xhr, settings]);
			},
			success: function(data, status, xhr) {
				element.trigger('ajax:success', [data, status, xhr]);
			},
			complete: function(xhr, status) {
				element.trigger('ajax:complete', [xhr, status]);
			},
			error: function(xhr, status, error) {
				element.trigger('ajax:error', [xhr, status, error]);
			}
		});
	}

	// Handles "data-method" on links such as:
	// <a href="/users/5" data-method="delete" rel="nofollow" data-confirm="Are you sure?">Delete</a>
	function handleMethod(link) {
		var href = link.attr('href'),
			method = link.attr('data-method'),
			csrf_token = $('meta[name=csrf-token]').attr('content'),
			csrf_param = $('meta[name=csrf-param]').attr('content'),
			form = $('<form method="post" action="' + href + '"></form>'),
			metadata_input = '<input name="_method" value="' + method + '" type="hidden" />';

		if (csrf_param !== undefined && csrf_token !== undefined) {
			metadata_input += '<input name="' + csrf_param + '" value="' + csrf_token + '" type="hidden" />';
		}

		form.hide().append(metadata_input).appendTo('body');
		form.submit();
	}

	function disableFormElements(form) {
		form.find('input[data-disable-with]').each(function() {
			var input = $(this);
			input.data('ujs:enable-with', input.val())
				.val(input.attr('data-disable-with'))
				.attr('disabled', 'disabled');
		});
	}

	function enableFormElements(form) {
		form.find('input[data-disable-with]').each(function() {
			var input = $(this);
			input.val(input.data('ujs:enable-with')).removeAttr('disabled');
		});
	}

	function allowAction(element) {
		var message = element.attr('data-confirm');
		return !message || (fire(element, 'confirm') && confirm(message));
	}

	function requiredValuesMissing(form) {
		var missing = false;
		form.find('input[name][required]').each(function() {
			if (!$(this).val()) missing = true;
		});
		return missing;
	}

	$('a[data-confirm], a[data-method], a[data-remote]').live('click.rails', function(e) {
		var link = $(this);
		if (!allowAction(link)) return false;

		if (link.attr('data-remote') != undefined) {
			handleRemote(link);
			return false;
		} else if (link.attr('data-method')) {
			handleMethod(link);
			return false;
		}
	});

	$('form').live('submit.rails', function(e) {
		var form = $(this), remote = form.attr('data-remote') != undefined;
		if (!allowAction(form)) return false;

		// skip other logic when required values are missing
		if (requiredValuesMissing(form)) return !remote;

		if (remote) {
			handleRemote(form);
			return false;
		} else {
			// slight timeout so that the submit button gets properly serialized
			setTimeout(function(){ disableFormElements(form) }, 13);
		}
	});

	$('form input[type=submit], form button[type=submit], form button:not([type])').live('click.rails', function() {
		var button = $(this);
		if (!allowAction(button)) return false;
		// register the pressed submit button
		var name = button.attr('name'), data = name ? {name:name, value:button.val()} : null;
		button.closest('form').data('ujs:submit-button', data);
	});
	
	$('form').live('ajax:beforeSend.rails', function(event) {
		if (this == event.target) disableFormElements($(this));
	});

	$('form').live('ajax:complete.rails', function(event) {
		if (this == event.target) enableFormElements($(this));
	});
})( jQuery );

/*
 ### jQuery Star Rating Plugin v3.13 - 2009-03-26 ###
 * Home: http://www.fyneworks.com/jquery/star-rating/
 * Code: http://code.google.com/p/jquery-star-rating-plugin/
 *
	* Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 ###
*/

/*# AVOID COLLISIONS #*/
;if(window.jQuery) (function($){
/*# AVOID COLLISIONS #*/
	
	// IE6 Background Image Fix
	if ($.browser.msie) try { document.execCommand("BackgroundImageCache", false, true)} catch(e) { };
	// Thanks to http://www.visualjquery.com/rating/rating_redux.html
	
	// plugin initialization
	$.fn.rating = function(options){
		if(this.length==0) return this; // quick fail
		
		// Handle API methods
		if(typeof arguments[0]=='string'){
			// Perform API methods on individual elements
			if(this.length>1){
				var args = arguments;
				return this.each(function(){
					$.fn.rating.apply($(this), args);
    });
			};
			// Invoke API method handler
			$.fn.rating[arguments[0]].apply(this, $.makeArray(arguments).slice(1) || []);
			// Quick exit...
			return this;
		};
		
		// Initialize options for this call
		var options = $.extend(
			{}/* new object */,
			$.fn.rating.options/* default options */,
			options || {} /* just-in-time options */
		);
		
		// Allow multiple controls with the same name by making each call unique
		$.fn.rating.calls++;
		
		// loop through each matched element
		this
		 .not('.star-rating-applied')
			.addClass('star-rating-applied')
		.each(function(){
			
			// Load control parameters / find context / etc
			var control, input = $(this);
			var eid = (this.name || 'unnamed-rating').replace(/\[|\]/g, '_').replace(/^\_+|\_+$/g,'');
			var context = $(this.form || document.body);
			
			// FIX: http://code.google.com/p/jquery-star-rating-plugin/issues/detail?id=23
			var raters = context.data('rating');
			if(!raters || raters.call!=$.fn.rating.calls) raters = { count:0, call:$.fn.rating.calls };
			var rater = raters[eid];
			
			// if rater is available, verify that the control still exists
			if(rater) control = rater.data('rating');
			
			if(rater && control)//{// save a byte!
				// add star to control if rater is available and the same control still exists
				control.count++;
				
			//}// save a byte!
			else{
				// create new control if first star or control element was removed/replaced
				
				// Initialize options for this raters
				control = $.extend(
					{}/* new object */,
					options || {} /* current call options */,
					($.metadata? input.metadata(): ($.meta?input.data():null)) || {}, /* metadata options */
					{ count:0, stars: [], inputs: [] }
				);
				
				// increment number of rating controls
				control.serial = raters.count++;
				
				// create rating element
				rater = $('<span class="star-rating-control"/>');
				input.before(rater);
				
				// Mark element for initialization (once all stars are ready)
				rater.addClass('rating-to-be-drawn');
				
				// Accept readOnly setting from 'disabled' property
				if(input.attr('disabled')) control.readOnly = true;
				
				// Create 'cancel' button
				rater.append(
					control.cancel = $('<div class="rating-cancel"><a title="' + control.cancel + '">' + control.cancelValue + '</a></div>')
					.mouseover(function(){
						$(this).rating('drain');
						$(this).addClass('star-rating-hover');
						//$(this).rating('focus');
					})
					.mouseout(function(){
						$(this).rating('draw');
						$(this).removeClass('star-rating-hover');
						//$(this).rating('blur');
					})
					.click(function(){
					 $(this).rating('select');
					})
					.data('rating', control)
				);
				
			}; // first element of group
			
			// insert rating star
			var star = $('<div class="star-rating rater-'+ control.serial +'"><a title="' + (this.title || this.value) + '">' + this.value + '</a></div>');
			rater.append(star);
			
			// inherit attributes from input element
			if(this.id) star.attr('id', this.id);
			if(this.className) star.addClass(this.className);
			
			// Half-stars?
			if(control.half) control.split = 2;
			
			// Prepare division control
			if(typeof control.split=='number' && control.split>0){
				var stw = ($.fn.width ? star.width() : 0) || control.starWidth;
				var spi = (control.count % control.split), spw = Math.floor(stw/control.split);
				star
				// restrict star's width and hide overflow (already in CSS)
				.width(spw)
				// move the star left by using a negative margin
				// this is work-around to IE's stupid box model (position:relative doesn't work)
				.find('a').css({ 'margin-left':'-'+ (spi*spw) +'px' })
			};
			
			// readOnly?
			if(control.readOnly)//{ //save a byte!
				// Mark star as readOnly so user can customize display
				star.addClass('star-rating-readonly');
			//}  //save a byte!
			else//{ //save a byte!
			 // Enable hover css effects
				star.addClass('star-rating-live')
				 // Attach mouse events
					.mouseover(function(){
						$(this).rating('fill');
						$(this).rating('focus');
					})
					.mouseout(function(){
						$(this).rating('draw');
						$(this).rating('blur');
					})
					.click(function(){
						$(this).rating('select');
					})
				;
			//}; //save a byte!
			
			// set current selection
			if(this.checked)	control.current = star;
			
			// hide input element
			input.hide();
			
			// backward compatibility, form element to plugin
			input.change(function(){
    $(this).rating('select');
   });
			
			// attach reference to star to input element and vice-versa
			star.data('rating.input', input.data('rating.star', star));
			
			// store control information in form (or body when form not available)
			control.stars[control.stars.length] = star[0];
			control.inputs[control.inputs.length] = input[0];
			control.rater = raters[eid] = rater;
			control.context = context;
			
			input.data('rating', control);
			rater.data('rating', control);
			star.data('rating', control);
			context.data('rating', raters);
  }); // each element
		
		// Initialize ratings (first draw)
		$('.rating-to-be-drawn').rating('draw').removeClass('rating-to-be-drawn');
		
		return this; // don't break the chain...
	};
	
	/*--------------------------------------------------------*/
	
	/*
		### Core functionality and API ###
	*/
	$.extend($.fn.rating, {
		// Used to append a unique serial number to internal control ID
		// each time the plugin is invoked so same name controls can co-exist
		calls: 0,
		
		focus: function(){
			var control = this.data('rating'); if(!control) return this;
			if(!control.focus) return this; // quick fail if not required
			// find data for event
			var input = $(this).data('rating.input') || $( this.tagName=='INPUT' ? this : null );
   // focus handler, as requested by focusdigital.co.uk
			if(control.focus) control.focus.apply(input[0], [input.val(), $('a', input.data('rating.star'))[0]]);
		}, // $.fn.rating.focus
		
		blur: function(){
			var control = this.data('rating'); if(!control) return this;
			if(!control.blur) return this; // quick fail if not required
			// find data for event
			var input = $(this).data('rating.input') || $( this.tagName=='INPUT' ? this : null );
   // blur handler, as requested by focusdigital.co.uk
			if(control.blur) control.blur.apply(input[0], [input.val(), $('a', input.data('rating.star'))[0]]);
		}, // $.fn.rating.blur
		
		fill: function(){ // fill to the current mouse position.
			var control = this.data('rating'); if(!control) return this;
			// do not execute when control is in read-only mode
			if(control.readOnly) return;
			// Reset all stars and highlight them up to this element
			this.rating('drain');
			this.prevAll().andSelf().filter('.rater-'+ control.serial).addClass('star-rating-hover');
		},// $.fn.rating.fill
		
		drain: function() { // drain all the stars.
			var control = this.data('rating'); if(!control) return this;
			// do not execute when control is in read-only mode
			if(control.readOnly) return;
			// Reset all stars
			control.rater.children().filter('.rater-'+ control.serial).removeClass('star-rating-on').removeClass('star-rating-hover');
		},// $.fn.rating.drain
		
		draw: function(){ // set value and stars to reflect current selection
			var control = this.data('rating'); if(!control) return this;
			// Clear all stars
			this.rating('drain');
			// Set control value
			if(control.current){
				control.current.data('rating.input').attr('checked','checked');
				control.current.prevAll().andSelf().filter('.rater-'+ control.serial).addClass('star-rating-on');
			}
			else
			 $(control.inputs).removeAttr('checked');
			// Show/hide 'cancel' button
			control.cancel[control.readOnly || control.required?'hide':'show']();
			// Add/remove read-only classes to remove hand pointer
			this.siblings()[control.readOnly?'addClass':'removeClass']('star-rating-readonly');
		},// $.fn.rating.draw
		
		
		
		
		
		select: function(value,wantCallBack){ // select a value
					
					// ***** MODIFICATION *****
					// Thanks to faivre.thomas - http://code.google.com/p/jquery-star-rating-plugin/issues/detail?id=27
					//
					// ***** LIST OF MODIFICATION *****
					// ***** added Parameter wantCallBack : false if you don't want a callback. true or undefined if you want postback to be performed at the end of this method'
					// ***** recursive calls to this method were like : ... .rating('select') it's now like .rating('select',undefined,wantCallBack); (parameters are set.)
					// ***** line which is calling callback
					// ***** /LIST OF MODIFICATION *****
			
			var control = this.data('rating'); if(!control) return this;
			// do not execute when control is in read-only mode
			if(control.readOnly) return;
			// clear selection
			control.current = null;
			// programmatically (based on user input)
			if(typeof value!='undefined'){
			 // select by index (0 based)
				if(typeof value=='number')
 			 return $(control.stars[value]).rating('select',undefined,wantCallBack);
				// select by literal value (must be passed as a string
				if(typeof value=='string')
					//return
					$.each(control.stars, function(){
						if($(this).data('rating.input').val()==value) $(this).rating('select',undefined,wantCallBack);
					});
			}
			else
				control.current = this[0].tagName=='INPUT' ?
				 this.data('rating.star') :
					(this.is('.rater-'+ control.serial) ? this : null);

			// Update rating control state
			this.data('rating', control);
			// Update display
			this.rating('draw');
			// find data for event
			var input = $( control.current ? control.current.data('rating.input') : null );
			// click callback, as requested here: http://plugins.jquery.com/node/1655
					
					// **** MODIFICATION *****
					// Thanks to faivre.thomas - http://code.google.com/p/jquery-star-rating-plugin/issues/detail?id=27
					//
					//old line doing the callback :
					//if(control.callback) control.callback.apply(input[0], [input.val(), $('a', control.current)[0]]);// callback event
					//
					//new line doing the callback (if i want :)
					if((wantCallBack ||wantCallBack == undefined) && control.callback) control.callback.apply(input[0], [input.val(), $('a', control.current)[0]]);// callback event
					//to ensure retro-compatibility, wantCallBack must be considered as true by default
					// **** /MODIFICATION *****
					
  },// $.fn.rating.select
		
		
		
		
		
		readOnly: function(toggle, disable){ // make the control read-only (still submits value)
			var control = this.data('rating'); if(!control) return this;
			// setread-only status
			control.readOnly = toggle || toggle==undefined ? true : false;
			// enable/disable control value submission
			if(disable) $(control.inputs).attr("disabled", "disabled");
			else     			$(control.inputs).removeAttr("disabled");
			// Update rating control state
			this.data('rating', control);
			// Update display
			this.rating('draw');
		},// $.fn.rating.readOnly
		
		disable: function(){ // make read-only and never submit value
			this.rating('readOnly', true, true);
		},// $.fn.rating.disable
		
		enable: function(){ // make read/write and submit value
			this.rating('readOnly', false, false);
		}// $.fn.rating.select
		
 });
	
	/*--------------------------------------------------------*/
	
	/*
		### Default Settings ###
		eg.: You can override default control like this:
		$.fn.rating.options.cancel = 'Clear';
	*/
	$.fn.rating.options = { //$.extend($.fn.rating, { options: {
			cancel: 'Cancel Rating',   // advisory title for the 'cancel' link
			cancelValue: '',           // value to submit when user click the 'cancel' link
			split: 0,                  // split the star into how many parts?
			
			// Width of star image in case the plugin can't work it out. This can happen if
			// the jQuery.dimensions plugin is not available OR the image is hidden at installation
			starWidth: 16//,
			
			//NB.: These don't need to be pre-defined (can be undefined/null) so let's save some code!
			//half:     false,         // just a shortcut to control.split = 2
			//required: false,         // disables the 'cancel' button so user can only select one of the specified values
			//readOnly: false,         // disable rating plugin interaction/ values cannot be changed
			//focus:    function(){},  // executed when stars are focused
			//blur:     function(){},  // executed when stars are focused
			//callback: function(){},  // executed when a star is clicked
 }; //} });
	
	/*--------------------------------------------------------*/
	
	/*
		### Default implementation ###
		The plugin will attach itself to file inputs
		with the class 'multi' when the page loads
	*/
	$(function(){
	 $('input[type=radio].star').rating();
	});
	
	
	
/*# AVOID COLLISIONS #*/
})(jQuery);
/*# AVOID COLLISIONS #*/

// $(function(){
// 
//   // if the user has signed in and the form is not shown yet , show it
//   FB.Event.subscribe('auth.login', function(response) {
//     login(response);
//   });
// 
// });

(function(){
  // all functions in this file are bound to the Window object to make em global.
  $(function() {
    window.compressText = function compressText(text, threshold) {
      var newText;
      if (text.length < threshold) {
        return text;
      }
      newText = text.substring(0, (threshold - 2));
      return newText + '...';
    };
    window.setElementCover = function setElementCover(element, toTake) {
      var anchor, threshold;
      anchor = '<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">';
      element.children('.stable').append(anchor + '<img src="http://spreadsong-book-covers.s3.amazonaws.com/book_id' + toTake[0].id + '_size3.jpg"/></a>');
      if (element.hasClass('cover-with-title-here')) {
        threshold = element.hasClass('small' || element.hasClass('tiny')) ? 40 : 61;
        element.append('<div class="text" style="display:none"> ' + anchor + '<span class="title">' + compressText(toTake[0].pretty_title, threshold) + '</span></a><span class="type">Book</span></div>');
      }
      return $('.cover-here img, .cover-with-title-here img').bind('load', function() {
        return $(this).parents('a').siblings('.spinner').fadeOut(200, function() {
          $(this).parents().siblings('.text').fadeIn(1000);
          return $(this).siblings('a').children('img').fadeIn(1000);
        });
      });
    };
    window.setCoverForAudiobook = function setCoverForAudiobook(element, toTake) {
      var anchor, threshold;
      anchor = '<a href="/' + toTake[0].author_slug + '/' + toTake[0].cached_slug + '" class="no-underline">';
      element.children('.stable').append(anchor + '<img src="http://spreadsong-audiobook-covers.s3.amazonaws.com/audiobook_id' + toTake[0].id + '_size3.jpg"/></a>');
      if (element.hasClass('cover-with-title-here')) {
        threshold = element.hasClass('small' || element.hasClass('tiny')) ? 40 : 61;
        element.append('<div class="text" style="display:none">' + anchor + '<span class="title">' + compressText(toTake[0].pretty_title, threshold) + '</span></a><span class="type">Audiobook</span></div>');
      }
      return $('.cover-here img, .cover-with-title-here img').bind('load', function() {
        return $(this).parents('a').siblings('.spinner').fadeOut(200, function() {
          $(this).parents().siblings('.text').fadeIn(1000);
          return $(this).siblings('a').children('img').fadeIn(1000);
        });
      });
    };
    return window.coversForRelatedBooks = function coversForRelatedBooks() {
      var allIds, audiobooks, data, url;
      allIds = $('ul.book-list li').map(function() {
        return $(this).attr('id').split('_')[1];
      });
      allIds = allIds.get();
      //determine if we are going to fetch audiobooks or books
      audiobooks = $('ul.book-list').hasClass('audiobooks');
      url = audiobooks ? 'json_audiobooks' : 'json_books';
      //create a single string:
      data = $(allIds).get().join(',');
      return $.getJSON(url, {
        id: data
      }, function(data) {
        return $.each(data, function(index, value) {
          var bookData, selector, str;
          //find book element:
          bookData = [value.attrs];
          str = audiobooks ? 'ul.book-list li#audiobook_' : ' ul.book-list li#book_';
          selector = str + value.attrs.id + ' .cover-here';
          //set the cover for this book
          return audiobooks ? setCoverForAudiobook($(selector), bookData) : setElementCover($(selector), bookData);
        });
      });
    };
  });
})();

(function(){
  $(function() {
    var audiobook, randomAudiobooks, randomBooks, totalAudiobooks, totalBooks, totalPopularCovers, url;
    // align small sized covers to the bottom in the related books container
    $('img.cover-art').each(function() {
      var addToTop, left, nLeft, nTop, top;
      if ($(this).height() < 155) {
        addToTop = 155 - $(this).height();
        nLeft = $(this).offset().left;
        nTop = $(this).offset().top + addToTop;
        return $(this).offset((top = nTop), (left = nLeft));
        // =============================== FILL POPULAR BOOKS COVERS:
        // fill up the popular book covers
      }
    });
    totalPopularCovers = $('#right-column .row .cover-here, #right-column .row .cover-with-title-here').size();
    if ($('#right-column .row').hasClass('audiobooks')) {
      url = '/random_json_audiobooks/';
      audiobook = true;
    } else {
      url = '/random_json_books/';
    }
    $.getJSON(url + totalPopularCovers, function(data) {
      return $.each($('#right-column .row .cover-here, #right-column .row .cover-with-title-here'), function(index, value) {
        var randCover, toTake, totalCovers;
        totalCovers = data.length;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        if (audiobook) {
          return setCoverForAudiobook($(this), toTake);
        } else {
          return setElementCover($(this), toTake);
          //=============================== FILL RANDOM BOOK COVERS (Main Page) IF EXIST:
        }
      });
    });
    randomBooks = $('.random-book');
    if (randomBooks.get(0)) {
      totalBooks = randomBooks.size();
    }
    randomBooks.get(0) ? $.getJSON('/random_json_books/' + totalBooks, function(data) {
      return $.each($('.random-book'), function(index, value) {
        var randCover, toTake, totalCovers;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        totalCovers = data.length;
        return setElementCover($(this), toTake);
        // ============================= FILL RANDOM AUDIOBOOK COVERS IF DEFINED
      });
    }) : null;
    randomAudiobooks = $('.random-audiobook');
    if (randomAudiobooks.get(0)) {
      totalAudiobooks = randomAudiobooks.size();
    }
    return randomAudiobooks.get(0) ? $.getJSON('/random_json_audiobooks/' + totalAudiobooks, function(data) {
      return $.each($('.random-audiobook'), function(index, value) {
        var randCover, toTake, totalCovers;
        randCover = Math.floor(Math.random() * totalCovers);
        toTake = data.splice(randCover, 1);
        totalCovers = data.length;
        return window.setCoverForAudiobook($(this), toTake);
      });
    }) : null;
  });
})();

/*************************************************
  **  jQuery Masonry version 1.3.2
  **  Copyright David DeSandro, licensed MIT
  **  http://desandro.com/resources/jquery-masonry
  **************************************************/
(function(e){var n=e.event,o;n.special.smartresize={setup:function(){e(this).bind("resize",n.special.smartresize.handler)},teardown:function(){e(this).unbind("resize",n.special.smartresize.handler)},handler:function(j,l){var g=this,d=arguments;j.type="smartresize";o&&clearTimeout(o);o=setTimeout(function(){jQuery.event.handle.apply(g,d)},l==="execAsap"?0:100)}};e.fn.smartresize=function(j){return j?this.bind("smartresize",j):this.trigger("smartresize",["execAsap"])};e.fn.masonry=function(j,l){var g=
 {getBricks:function(d,b,a){var c=a.itemSelector===undefined;b.$bricks=a.appendedContent===undefined?c?d.children():d.find(a.itemSelector):c?a.appendedContent:a.appendedContent.filter(a.itemSelector)},placeBrick:function(d,b,a,c,h){b=Math.min.apply(Math,a);for(var i=b+d.outerHeight(true),f=a.length,k=f,m=c.colCount+1-f;f--;)if(a[f]==b)k=f;d.applyStyle({left:c.colW*k+c.posLeft,top:b},e.extend(true,{},h.animationOptions));for(f=0;f<m;f++)c.colY[k+f]=i},setup:function(d,b,a){g.getBricks(d,a,b);if(a.masoned)a.previousData=
 d.data("masonry");a.colW=b.columnWidth===undefined?a.masoned?a.previousData.colW:a.$bricks.outerWidth(true):b.columnWidth;a.colCount=Math.floor(d.width()/a.colW);a.colCount=Math.max(a.colCount,1)},arrange:function(d,b,a){var c;if(!a.masoned||b.appendedContent!==undefined)a.$bricks.css("position","absolute");if(a.masoned){a.posTop=a.previousData.posTop;a.posLeft=a.previousData.posLeft}else{d.css("position","relative");var h=e(document.createElement("div"));d.prepend(h);a.posTop=Math.round(h.position().top);
 a.posLeft=Math.round(h.position().left);h.remove()}if(a.masoned&&b.appendedContent!==undefined){a.colY=a.previousData.colY;for(c=a.previousData.colCount;c<a.colCount;c++)a.colY[c]=a.posTop}else{a.colY=[];for(c=a.colCount;c--;)a.colY.push(a.posTop)}e.fn.applyStyle=a.masoned&&b.animate?e.fn.animate:e.fn.css;b.singleMode?a.$bricks.each(function(){var i=e(this);g.placeBrick(i,a.colCount,a.colY,a,b)}):a.$bricks.each(function(){var i=e(this),f=Math.ceil(i.outerWidth(true)/a.colW);f=Math.min(f,a.colCount);
   if(f===1)g.placeBrick(i,a.colCount,a.colY,a,b);else{var k=a.colCount+1-f,m=[];for(c=0;c<k;c++){var p=a.colY.slice(c,c+f);m[c]=Math.max.apply(Math,p)}g.placeBrick(i,k,m,a,b)}});a.wallH=Math.max.apply(Math,a.colY);d.applyStyle({height:a.wallH-a.posTop},e.extend(true,[],b.animationOptions));a.masoned||setTimeout(function(){d.addClass("masoned")},1);l.call(a.$bricks);d.data("masonry",a)},resize:function(d,b,a){a.masoned=!!d.data("masonry");var c=d.data("masonry").colCount;g.setup(d,b,a);a.colCount!=c&&
 g.arrange(d,b,a)}};return this.each(function(){var d=e(this),b={};b.masoned=!!d.data("masonry");var a=b.masoned?d.data("masonry").options:{},c=e.extend({},e.fn.masonry.defaults,a,j),h=a.resizeable;b.options=c.saveOptions?c:a;l=l||function(){};g.getBricks(d,b,c);if(!b.$bricks.length)return this;g.setup(d,c,b);g.arrange(d,c,b);!h&&c.resizeable&&e(window).bind("smartresize.masonry",function(){g.resize(d,c,b)});h&&!c.resizeable&&e(window).unbind("smartresize.masonry")})};e.fn.masonry.defaults={singleMode:false,
 columnWidth:undefined,itemSelector:undefined,appendedContent:undefined,saveOptions:true,resizeable:true,animate:false,animationOptions:{}}})(jQuery);

