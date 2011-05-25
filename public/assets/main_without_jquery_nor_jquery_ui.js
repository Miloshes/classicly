(function($){$.extend({metadata:{defaults:{type:"class",name:"metadata",cre:/({.*})/,single:"metadata"},setType:function(type,name){this.defaults.type=type;this.defaults.name=name},get:function(elem,opts){var settings=$.extend({},this.defaults,opts);if(!settings.single.length){settings.single="metadata"}var data=$.data(elem,settings.single);if(data){return data}data="{}";var getData=function(data){if(typeof data!="string"){return data}if(data.indexOf("{")<0){data=eval("("+data+")")}};var getObject=function(data){if(typeof data!="string"){return data}data=eval("("+data+")");return data};if(settings.type=="html5"){var object={};$(elem.attributes).each(function(){var name=this.nodeName;if(name.match(/^data-/)){name=name.replace(/^data-/,"")}else{return true}object[name]=getObject(this.nodeValue)})}else{if(settings.type=="class"){var m=settings.cre.exec(elem.className);if(m){data=m[1]}}else{if(settings.type=="elem"){if(!elem.getElementsByTagName){return}var e=elem.getElementsByTagName(settings.name);if(e.length){data=$.trim(e[0].innerHTML)}}else{if(elem.getAttribute!=undefined){var attr=elem.getAttribute(settings.name);if(attr){data=attr}}}}object=getObject(data.indexOf("{")<0?"{"+data+"}":data)}$.data(elem,settings.single,object);return object}}});$.fn.metadata=function(opts){return $.metadata.get(this[0],opts)}})(jQuery);(function(){$(function(){var a;a=function a(){};a.prototype.init=function b(){return a.prototype.initCovers()};a.prototype.initCovers=function c(){var d;d=$(".random-book").size();return $.getJSON("/random_json_books/"+d,function(e){return $.each($(".random-book"),function(h,j){var g,f,i;g=Math.floor(Math.random()*i);f=e.splice(g,1);i=e.length;return setElementCover($(this),f)})})};window.Cover=new a();return window.Cover.init()})})();function Global(){this.init=function(){Global.installObservers();Cover.init();$(".radio").buttonset();FB.Event.subscribe("auth.logout",function(c){$("#nav").html("")});$("#registration a.fb_button").live("click",function(){if(RAILS_ENV=="production"){_paq.push(["trackConversion",{id:"7SXbBD9Fp588",value:null}]);mpmetrics.track("FB Login Clicked")}});FB.Event.subscribe("edge.create",function(c){liked_url=c;if(RAILS_ENV=="production"){_paq.push(["trackConversion",{id:"6Sk7qc8EKYUF",value:null}]);FB.getLoginStatus(function(d){if(d.session){id=d.session.uid;mpmetrics.track("Facebook Like Book",{fb_uid:id,url:liked_url})}else{mpmetrics.track("Facebook Like Book",{url:liked_url})}})}});$("#apple-store-banner").click(function(){if(RAILS_ENV=="production"){mpmetrics.track("AppleStore Banner Clicked")}});function a(c){var d=FB.Data.query("select first_name, hometown_location, pic_small from user where uid={0}",c.session.uid);d.wait(function(e){first_name=e[0].first_name;pic=e[0].pic_small;if(e[0].hometown_location==null){city="";country=""}else{city=e[0].hometown_location.city;country=e[0].hometown_location.country}b(pic,first_name);$.ajax({type:"POST",url:"/logins",dataType:"json",data:"country="+country+"&city="+city,success:function(f){if(f.new_login&&RAILS_ENV=="production"){_paq.push(["trackConversion",{id:"3F6mY45twfux",value:null}])}}})});$("#registration a").addClass("displaced")}function b(c,d){$("#nav").html('<div id="user_welcome"><img src="'+c+'"/><span class="name">Welcome back, '+d+"!</span></div>")}};this.installObservers=function(){}}Global=new Global();$(function(){var a=a||[]});function coversForRelatedBooks(){var d,c,b,a;d=$("ul.book-list li").map(function(){return $(this).attr("id").split("_")[1]});d=d.get();b=$("ul.book-list").hasClass("audiobooks");b?(a="json_audiobooks"):(a="json_books");c=$(d).get().join(",");return $.getJSON(a,{id:c},function(e){return $.each(e,function(g,h){var j,f,i;j=[h.attrs];i=b?"ul.book-list li#audiobook_":"ul.book-list li#book_";f=i+h.attrs.id+" .cover-here";b?setCoverForAudiobook($(f),j):setElementCover($(f),j)})})}function setElementCover(b,a){b.children(".stable").append('<img src="http://spreadsong-book-covers.s3.amazonaws.com/book_id'+a[0].id+'_size3.jpg"/>');b.wrap('<a href="/'+a[0].author_slug+"/"+a[0].cached_slug+'" class="no-underline">');b.hasClass("cover-with-title-here")?b.append('<div class="text" style="display:none"><span class="title">'+a[0].pretty_title+'</span><span class="type">Book</span></div>'):null;$(".cover-here img, .cover-with-title-here img").bind("load",function(){$(this).siblings(".spinner").fadeOut(200,function(){$(this).parents().siblings(".text").fadeIn(1000);$(this).siblings("img").fadeIn(1000)})})}function setCoverForAudiobook(b,a){b.children(".stable").append('<img src="http://spreadsong-audiobook-covers.s3.amazonaws.com/audiobook_id'+a[0].id+'_size3.jpg"/>');b.wrap('<a href="/'+a[0].author_slug+"/"+a[0].cached_slug+'" class="no-underline">');b.hasClass("cover-with-title-here")?b.append('<div class="text" style="display:none"><span class="title">'+a[0].pretty_title+'</span><span class="type">Audiobook</span></div>'):null;$(".cover-here img, .cover-with-title-here img").bind("load",function(){$(this).siblings(".spinner").fadeOut(200,function(){$(this).parents().siblings(".text").fadeIn(1000);$(this).siblings("img").fadeIn(1000)})})}(function(d){function b(k){var j=d('meta[name="csrf-token"]').attr("content");if(j){k.setRequestHeader("X-CSRF-Token",j)}}if("ajaxPrefilter" in d){d.ajaxPrefilter(function(j,l,k){b(k)})}else{d(document).ajaxSend(function(j,k){b(k)})}function c(m,j,l){var k=new d.Event(j);m.trigger(k,l);return k.result!==false}function i(m){var o,k,n,j=m.attr("data-type")||(d.ajaxSettings&&d.ajaxSettings.dataType);if(m.is("form")){o=m.attr("method");k=m.attr("action");n=m.serializeArray();var l=m.data("ujs:submit-button");if(l){n.push(l);m.data("ujs:submit-button",null)}}else{o=m.attr("data-method");k=m.attr("href");n=null}d.ajax({url:k,type:o||"GET",data:n,dataType:j,beforeSend:function(q,p){if(p.dataType===undefined){q.setRequestHeader("accept","*/*;q=0.5, "+p.accepts.script)}return c(m,"ajax:beforeSend",[q,p])},success:function(q,p,r){m.trigger("ajax:success",[q,p,r])},complete:function(q,p){m.trigger("ajax:complete",[q,p])},error:function(r,p,q){m.trigger("ajax:error",[r,p,q])}})}function f(n){var k=n.attr("href"),p=n.attr("data-method"),l=d("meta[name=csrf-token]").attr("content"),o=d("meta[name=csrf-param]").attr("content"),m=d('<form method="post" action="'+k+'"></form>'),j='<input name="_method" value="'+p+'" type="hidden" />';if(o!==undefined&&l!==undefined){j+='<input name="'+o+'" value="'+l+'" type="hidden" />'}m.hide().append(j).appendTo("body");m.submit()}function g(j){j.find("input[data-disable-with]").each(function(){var k=d(this);k.data("ujs:enable-with",k.val()).val(k.attr("data-disable-with")).attr("disabled","disabled")})}function a(j){j.find("input[data-disable-with]").each(function(){var k=d(this);k.val(k.data("ujs:enable-with")).removeAttr("disabled")})}function h(j){var k=j.attr("data-confirm");return !k||(c(j,"confirm")&&confirm(k))}function e(k){var j=false;k.find("input[name][required]").each(function(){if(!d(this).val()){j=true}});return j}d("a[data-confirm], a[data-method], a[data-remote]").live("click.rails",function(k){var j=d(this);if(!h(j)){return false}if(j.attr("data-remote")!=undefined){i(j);return false}else{if(j.attr("data-method")){f(j);return false}}});d("form").live("submit.rails",function(l){var j=d(this),k=j.attr("data-remote")!=undefined;if(!h(j)){return false}if(e(j)){return !k}if(k){i(j);return false}else{setTimeout(function(){g(j)},13)}});d("form input[type=submit], form button[type=submit], form button:not([type])").live("click.rails",function(){var k=d(this);if(!h(k)){return false}var j=k.attr("name"),l=j?{name:j,value:k.val()}:null;k.closest("form").data("ujs:submit-button",l)});d("form").live("ajax:beforeSend.rails",function(j){if(this==j.target){g(d(this))}});d("form").live("ajax:complete.rails",function(j){if(this==j.target){a(d(this))}})})(jQuery);if(window.jQuery){(function(a){if(a.browser.msie){try{document.execCommand("BackgroundImageCache",false,true)}catch(b){}}a.fn.rating=function(d){if(this.length==0){return this}if(typeof arguments[0]=="string"){if(this.length>1){var c=arguments;return this.each(function(){a.fn.rating.apply(a(this),c)})}a.fn.rating[arguments[0]].apply(this,a.makeArray(arguments).slice(1)||[]);return this}var d=a.extend({},a.fn.rating.options,d||{});a.fn.rating.calls++;this.not(".star-rating-applied").addClass("star-rating-applied").each(function(){var g,l=a(this);var e=(this.name||"unnamed-rating").replace(/\[|\]/g,"_").replace(/^\_+|\_+$/g,"");var f=a(this.form||document.body);var k=f.data("rating");if(!k||k.call!=a.fn.rating.calls){k={count:0,call:a.fn.rating.calls}}var n=k[e];if(n){g=n.data("rating")}if(n&&g){g.count++}else{g=a.extend({},d||{},(a.metadata?l.metadata():(a.meta?l.data():null))||{},{count:0,stars:[],inputs:[]});g.serial=k.count++;n=a('<span class="star-rating-control"/>');l.before(n);n.addClass("rating-to-be-drawn");if(l.attr("disabled")){g.readOnly=true}n.append(g.cancel=a('<div class="rating-cancel"><a title="'+g.cancel+'">'+g.cancelValue+"</a></div>").mouseover(function(){a(this).rating("drain");a(this).addClass("star-rating-hover")}).mouseout(function(){a(this).rating("draw");a(this).removeClass("star-rating-hover")}).click(function(){a(this).rating("select")}).data("rating",g))}var j=a('<div class="star-rating rater-'+g.serial+'"><a title="'+(this.title||this.value)+'">'+this.value+"</a></div>");n.append(j);if(this.id){j.attr("id",this.id)}if(this.className){j.addClass(this.className)}if(g.half){g.split=2}if(typeof g.split=="number"&&g.split>0){var i=(a.fn.width?j.width():0)||g.starWidth;var h=(g.count%g.split),m=Math.floor(i/g.split);j.width(m).find("a").css({"margin-left":"-"+(h*m)+"px"})}if(g.readOnly){j.addClass("star-rating-readonly")}else{j.addClass("star-rating-live").mouseover(function(){a(this).rating("fill");a(this).rating("focus")}).mouseout(function(){a(this).rating("draw");a(this).rating("blur")}).click(function(){a(this).rating("select")})}if(this.checked){g.current=j}l.hide();l.change(function(){a(this).rating("select")});j.data("rating.input",l.data("rating.star",j));g.stars[g.stars.length]=j[0];g.inputs[g.inputs.length]=l[0];g.rater=k[e]=n;g.context=f;l.data("rating",g);n.data("rating",g);j.data("rating",g);f.data("rating",k)});a(".rating-to-be-drawn").rating("draw").removeClass("rating-to-be-drawn");return this};a.extend(a.fn.rating,{calls:0,focus:function(){var d=this.data("rating");if(!d){return this}if(!d.focus){return this}var c=a(this).data("rating.input")||a(this.tagName=="INPUT"?this:null);if(d.focus){d.focus.apply(c[0],[c.val(),a("a",c.data("rating.star"))[0]])}},blur:function(){var d=this.data("rating");if(!d){return this}if(!d.blur){return this}var c=a(this).data("rating.input")||a(this.tagName=="INPUT"?this:null);if(d.blur){d.blur.apply(c[0],[c.val(),a("a",c.data("rating.star"))[0]])}},fill:function(){var c=this.data("rating");if(!c){return this}if(c.readOnly){return}this.rating("drain");this.prevAll().andSelf().filter(".rater-"+c.serial).addClass("star-rating-hover")},drain:function(){var c=this.data("rating");if(!c){return this}if(c.readOnly){return}c.rater.children().filter(".rater-"+c.serial).removeClass("star-rating-on").removeClass("star-rating-hover")},draw:function(){var c=this.data("rating");if(!c){return this}this.rating("drain");if(c.current){c.current.data("rating.input").attr("checked","checked");c.current.prevAll().andSelf().filter(".rater-"+c.serial).addClass("star-rating-on")}else{a(c.inputs).removeAttr("checked")}c.cancel[c.readOnly||c.required?"hide":"show"]();this.siblings()[c.readOnly?"addClass":"removeClass"]("star-rating-readonly")},select:function(d,f){var e=this.data("rating");if(!e){return this}if(e.readOnly){return}e.current=null;if(typeof d!="undefined"){if(typeof d=="number"){return a(e.stars[d]).rating("select",undefined,f)}if(typeof d=="string"){a.each(e.stars,function(){if(a(this).data("rating.input").val()==d){a(this).rating("select",undefined,f)}})}}else{e.current=this[0].tagName=="INPUT"?this.data("rating.star"):(this.is(".rater-"+e.serial)?this:null)}this.data("rating",e);this.rating("draw");var c=a(e.current?e.current.data("rating.input"):null);if((f||f==undefined)&&e.callback){e.callback.apply(c[0],[c.val(),a("a",e.current)[0]])}},readOnly:function(c,d){var e=this.data("rating");if(!e){return this}e.readOnly=c||c==undefined?true:false;if(d){a(e.inputs).attr("disabled","disabled")}else{a(e.inputs).removeAttr("disabled")}this.data("rating",e);this.rating("draw")},disable:function(){this.rating("readOnly",true,true)},enable:function(){this.rating("readOnly",false,false)}});a.fn.rating.options={cancel:"Cancel Rating",cancelValue:"",split:0,starWidth:16};a(function(){a("input[type=radio].star").rating()})})(jQuery)};