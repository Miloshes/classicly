UIHandler=function(){};UIHandler.prototype={getAutocompleteHeight:function(){return $("ul.ui-autocomplete").height()},removeSigninMessage:function(){html="<div id='profile-pic'><a href='/library'><img src= 'http://graph.facebook.com/"+this.uid+"/picture?type=square'/></a></div>";$(".top #signin").remove();$(html).insertAfter("#nav")},setuid:function(a){this.uid=a},slideDownContentContainer:function(){var a=this.getAutocompleteHeight()+10;$("#content").css("margin-top",a+"px")},slideUpContentContainer:function(){$("#content").css("margin-top","0px")}};Function.prototype.bind=function(a,b){this.prototype[a]=b};var LoginsController=function(a){this.uiHandler=a};LoginsController.prototype={dropLoginDrawer:function(b){var a=$("#fb_connect_notification");if(b){a.addClass("fixed")}else{a.removeClass("fixed")}if(this.userLoggedIn()){return false}else{if(a.is(":hidden")){a.slideDown("slow")}}},hideLoginDrawer:function(){var a=$("#fb_connect_notification");if(a.is(":visible")){a.slideUp("slow")}},logIn:function(){var a=this;FB.login(function(b){if(b.authResponse){a.uiHandler.setuid(b.authResponse.uid);$.ajax({type:"POST",url:"/logins",dataType:"json",success:function(c){a.pushToKissmetrics(c);if(a.afterLoggedIn!=undefined){a.afterLoggedIn()}a.hideLoginDrawer();a.uiHandler.removeSigninMessage()}})}},{scope:"email"})},pushToKissmetrics:function(a){if(_kmq==undefined){console.log("Kissmetrics is undefined");return false}if(a.is_new_login==false){_kmq.push(["record","User Signed In"])}else{_kmq.push(["record","User Signed Up"])}},userLoggedIn:function(){var a=false;FB.getLoginStatus(function(b){if(b.status=="connected"){a=true}});return a}};var RatingsController=function(b,a){this.uiHandler=a;this.loginsController=b};var showStarsOnRatingComplete=function(b,a,c){ratingTextDiv=$(b);ratingTextDiv.text("My Rating:");$(a).show();$(c).hide()};RatingsController.prototype={hideStarsOnRating:function(){ratingTextDiv=$(this.settings.ratingTextDOM);ratingTextDiv.text("Saving...");$(this.settings.ratingStarsDOM).hide();$(this.settings.blankStarsDOM).show()},sendRate:function(g,e,a,d){var f=a+"_id="+g+"&rating="+e;var c="/reviews/create_rating";var b=this;b.settings=$.extend({ratingTextDOM:".cover-column #my-rating #text",ratingStarsDOM:"#my-rating #rating-stars",blankStarsDOM:"#my-rating #blank-stars"},d||{});$.ajax({type:"POST",url:c,data:f,beforeSend:this.hideStarsOnRating(),success:function(){ratingTextDiv=$(b.settings.ratingTextDOM);ratingTextDiv.text("Saved!");setTimeout("showStarsOnRatingComplete('"+b.settings.ratingTextDOM+"', '"+b.settings.ratingStarsDOM+"','"+b.settings.blankStarsDOM+"')",200)}})}};var uiHandler=new UIHandler();var loginsController=new LoginsController(uiHandler);$(function(){$("#signin a").click(function(){loginsController.dropLoginDrawer(false);return false});$("#fb_connect_notification a#fb_connect").click(function(){loginsController.logIn();return false});$(".audiobook-switcher a").tooltip({tip:".tooltip",effect:"fade",fadeOutSpeed:100,predelay:0,position:"bottom right",offset:[-25,5]});$("#search #indexTankForm").submit(function(){var a=$(this).find("#term").val();if(_gaq){_gaq.push(["_trackEvent","search_events","search",a])}});$("#fb_connect_notification a#fb_decline").click(function(){loginsController.hideLoginDrawer();return false});$(".pagination ul li.active, .pagination ul li.gap").live("click",function(){return false})});function sendKissMetricsEvent(b,a){if(_kmq){if(a){_kmq.push(["record",b,a])}else{_kmq.push(["record",b])}}}function unique(d){var a=new Array();label:for(var c=0;c<d.length;c++){for(var b=0;b<a.length;b++){if(a[b]==d[c]){continue label}}a[a.length]=d[c]}return a}function compressText(b,a){if(b.length>a){b=b.substring(0,(a-3));b+="..."}return b}function ssLess(e,a){var d=new Array();$("<div>"+e+"</div>").find("b").each(function(f,g){d.push($(this).text())});var c=e.replace(/<.*?>/g,"");var b=compressText(c,a);for(index in d){b=b.replace(d[index],"<b>"+d[index]+"</b>")}return b}var elementId="#term";var apiUrl="http://classicly.api.houndsleuth.com";var indexName="ClassiclyAutocomplete";var source=apiUrl+"/v1/indexes/"+indexName+"/search";var searchResults;var uiHandler=new UIHandler();$.ui["autocomplete"].prototype._renderItem=function(b,c){var a;if(c.type=="book"||c.type=="audiobook"){a="<div class='with-cover'><img src='"+c.cover_url+"'class='micro-cover'><span class='text'>"+ssLess(c.label,40)+"<span class='type'>"+c.type+"</span></span></div>"}else{if(c.type=="collection"){a=c.label+"<span class='type'>"+c.type+"</span>"}else{a=c.label}}return $("<li></li>").data("item.autocomplete",c).append($("<a></a>").html(a)).appendTo(b)};google.setOnLoadCallback(function(){$(function(){var b=function(d,c){searchResults=[];$.ajax({url:apiUrl+"/v1/indexes/"+indexName+"/autocomplete",dataType:"jsonp",data:{query:d.term,field:"text"},success:function(e){$.ajax({url:source,dataType:"jsonp",data:{len:10,q:"("+e.suggestions[0]+") OR full:"+e.suggestions[0].replace(" ","")+"^100000",snippet:"text",fetch:"text,type,slug,cover_url"},success:function(f){$.map(f.results,function(g){searchResults.push({label:g.snippet_text,value:g.text,type:g.type,slug:g.slug,cover_url:g.cover_url})});searchResults.push({label:"search <b>"+d.term+"</b>",value:d.term});c($.each(searchResults,function(h,g){return{label:g.label,value:g.value}}))}})}})};var a=function(c,d){c.target.value=d.item.value;if(d.item.slug!=undefined){window.location="http://www.classicly.com"+d.item.slug}else{$(c.target.form).submit()}};$(elementId).autocomplete({source:b,delay:250,select:a,open:function(c,d){uiHandler.slideDownContentContainer()},close:function(c,d){uiHandler.slideUpContentContainer()}})})});if(window.jQuery){(function(a){if(a.browser.msie){try{document.execCommand("BackgroundImageCache",false,true)}catch(b){}}a.fn.rating=function(d){if(this.length==0){return this}if(typeof arguments[0]=="string"){if(this.length>1){var c=arguments;return this.each(function(){a.fn.rating.apply(a(this),c)})}a.fn.rating[arguments[0]].apply(this,a.makeArray(arguments).slice(1)||[]);return this}var d=a.extend({},a.fn.rating.options,d||{});a.fn.rating.calls++;this.not(".star-rating-applied").addClass("star-rating-applied").each(function(){var g,l=a(this);var e=(this.name||"unnamed-rating").replace(/\[|\]/g,"_").replace(/^\_+|\_+$/g,"");var f=a(this.form||document.body);var k=f.data("rating");if(!k||k.call!=a.fn.rating.calls){k={count:0,call:a.fn.rating.calls}}var n=k[e];if(n){g=n.data("rating")}if(n&&g){g.count++}else{g=a.extend({},d||{},(a.metadata?l.metadata():(a.meta?l.data():null))||{},{count:0,stars:[],inputs:[]});g.serial=k.count++;n=a('<span class="star-rating-control"/>');l.before(n);n.addClass("rating-to-be-drawn");if(l.attr("disabled")){g.readOnly=true}n.append(g.cancel=a('<div class="rating-cancel"><a title="'+g.cancel+'">'+g.cancelValue+"</a></div>").mouseover(function(){a(this).rating("drain");a(this).addClass("star-rating-hover")}).mouseout(function(){a(this).rating("draw");a(this).removeClass("star-rating-hover")}).click(function(){a(this).rating("select")}).data("rating",g))}var j=a('<div class="star-rating rater-'+g.serial+'"><a title="'+(this.title||this.value)+'">'+this.value+"</a></div>");n.append(j);if(this.id){j.attr("id",this.id)}if(this.className){j.addClass(this.className)}if(g.half){g.split=2}if(typeof g.split=="number"&&g.split>0){var i=(a.fn.width?j.width():0)||g.starWidth;var h=(g.count%g.split),m=Math.floor(i/g.split);j.width(m).find("a").css({"margin-left":"-"+(h*m)+"px"})}if(g.readOnly){j.mouseover(function(){a(this).rating("fill");a(this).rating("focus")}).mouseout(function(){a(this).rating("draw");a(this).rating("blur")})}else{j.addClass("star-rating-live").mouseover(function(){a(this).rating("fill");a(this).rating("focus")}).mouseout(function(){a(this).rating("draw");a(this).rating("blur")}).click(function(){a(this).rating("select")})}if(this.checked){g.current=j}l.hide();l.change(function(){a(this).rating("select")});j.data("rating.input",l.data("rating.star",j));g.stars[g.stars.length]=j[0];g.inputs[g.inputs.length]=l[0];g.rater=k[e]=n;g.context=f;l.data("rating",g);n.data("rating",g);j.data("rating",g);f.data("rating",k)});a(".rating-to-be-drawn").rating("draw").removeClass("rating-to-be-drawn");return this};a.extend(a.fn.rating,{calls:0,focus:function(){var d=this.data("rating");if(!d){return this}if(!d.focus){return this}var c=a(this).data("rating.input")||a(this.tagName=="INPUT"?this:null);if(d.focus){d.focus.apply(c[0],[c.val(),a("a",c.data("rating.star"))[0]])}},blur:function(){var d=this.data("rating");if(!d){return this}if(!d.blur){return this}var c=a(this).data("rating.input")||a(this.tagName=="INPUT"?this:null);if(d.blur){d.blur.apply(c[0],[c.val(),a("a",c.data("rating.star"))[0]])}},fill:function(){var c=this.data("rating");if(!c){return this}this.rating("drain");this.prevAll().andSelf().filter(".rater-"+c.serial).addClass("star-rating-hover")},drain:function(){var c=this.data("rating");if(!c){return this}c.rater.children().filter(".rater-"+c.serial).removeClass("star-rating-on").removeClass("star-rating-hover")},draw:function(){var c=this.data("rating");if(!c){return this}this.rating("drain");if(c.current){c.current.data("rating.input").attr("checked","checked");c.current.prevAll().andSelf().filter(".rater-"+c.serial).addClass("star-rating-on")}else{a(c.inputs).removeAttr("checked")}c.cancel[c.readOnly||c.required?"hide":"show"]()},select:function(d,f){var e=this.data("rating");if(!e){return this}if(e.readOnly){if(!(isLoggedIn())){if(a("#fb_connect_notification").is(":hidden")){a("#fb_connect_notification ").slideDown("slow")}}return}e.current=null;if(typeof d!="undefined"){if(typeof d=="number"){return a(e.stars[d]).rating("select",undefined,f)}if(typeof d=="string"){a.each(e.stars,function(){if(a(this).data("rating.input").val()==d){a(this).rating("select",undefined,f)}})}}else{e.current=this[0].tagName=="INPUT"?this.data("rating.star"):(this.is(".rater-"+e.serial)?this:null)}this.data("rating",e);this.rating("draw");var c=a(e.current?e.current.data("rating.input"):null);if((f||f==undefined)&&e.callback){e.callback.apply(c[0],[c.val(),a("a",e.current)[0]])}},readOnly:function(c,d){var e=this.data("rating");if(!e){return this}e.readOnly=c||c==undefined?true:false;if(d){a(e.inputs).attr("disabled","disabled")}else{a(e.inputs).removeAttr("disabled")}this.data("rating",e);this.rating("draw")},disable:function(){this.rating("readOnly",true,true)},enable:function(){this.rating("readOnly",false,false)}});a.fn.rating.options={cancel:"Cancel Rating",cancelValue:"",split:0,starWidth:16};a(function(){a("input[type=radio].star").rating()})})(jQuery)}(function(d){function b(k){var j=d('meta[name="csrf-token"]').attr("content");if(j){k.setRequestHeader("X-CSRF-Token",j)}}if("ajaxPrefilter" in d){d.ajaxPrefilter(function(j,l,k){b(k)})}else{d(document).ajaxSend(function(j,k){b(k)})}function c(m,j,l){var k=new d.Event(j);m.trigger(k,l);return k.result!==false}function i(m){var o,k,n,j=m.attr("data-type")||(d.ajaxSettings&&d.ajaxSettings.dataType);if(m.is("form")){o=m.attr("method");k=m.attr("action");n=m.serializeArray();var l=m.data("ujs:submit-button");if(l){n.push(l);m.data("ujs:submit-button",null)}}else{o=m.attr("data-method");k=m.attr("href");n=null}d.ajax({url:k,type:o||"GET",data:n,dataType:j,beforeSend:function(q,p){if(p.dataType===undefined){q.setRequestHeader("accept","*/*;q=0.5, "+p.accepts.script)}return c(m,"ajax:beforeSend",[q,p])},success:function(q,p,r){m.trigger("ajax:success",[q,p,r])},complete:function(q,p){m.trigger("ajax:complete",[q,p])},error:function(r,p,q){m.trigger("ajax:error",[r,p,q])}})}function f(n){var k=n.attr("href"),p=n.attr("data-method"),l=d("meta[name=csrf-token]").attr("content"),o=d("meta[name=csrf-param]").attr("content"),m=d('<form method="post" action="'+k+'"></form>'),j='<input name="_method" value="'+p+'" type="hidden" />';if(o!==undefined&&l!==undefined){j+='<input name="'+o+'" value="'+l+'" type="hidden" />'}m.hide().append(j).appendTo("body");m.submit()}function g(j){j.find("input[data-disable-with]").each(function(){var k=d(this);k.data("ujs:enable-with",k.val()).val(k.attr("data-disable-with")).attr("disabled","disabled")})}function a(j){j.find("input[data-disable-with]").each(function(){var k=d(this);k.val(k.data("ujs:enable-with")).removeAttr("disabled")})}function h(j){var k=j.attr("data-confirm");return !k||(c(j,"confirm")&&confirm(k))}function e(k){var j=false;k.find("input[name][required]").each(function(){if(!d(this).val()){j=true}});return j}d("a[data-confirm], a[data-method], a[data-remote]").live("click.rails",function(k){var j=d(this);if(!h(j)){return false}if(j.attr("data-remote")!=undefined){i(j);return false}else{if(j.attr("data-method")){f(j);return false}}});d("form").live("submit.rails",function(l){var j=d(this),k=j.attr("data-remote")!=undefined;if(!h(j)){return false}if(e(j)){return !k}if(k){i(j);return false}else{setTimeout(function(){g(j)},13)}});d("form input[type=submit], form button[type=submit], form button:not([type])").live("click.rails",function(){var k=d(this);if(!h(k)){return false}var j=k.attr("name"),l=j?{name:j,value:k.val()}:null;k.closest("form").data("ujs:submit-button",l)});d("form").live("ajax:beforeSend.rails",function(j){if(this==j.target){g(d(this))}});d("form").live("ajax:complete.rails",function(j){if(this==j.target){a(d(this))}})})(jQuery);function hideGlobalNotifications(a){$(".global-notification").each(function(){var b=0;if(a){b=500}if($(this).is(":visible")){$(this).animate({top:"-="+$(this).outerHeight()},{duration:b,easing:"swing",complete:function(){$(this).hide()}});$("#site-container").animate({top:"-="+$(this).outerHeight()},{duration:b,easing:"swing"})}})}function showGlobalNotifications(){$(".global-notification").each(function(){animation_length=500;if(!$(this).is(":visible")){$(this).show();$(this).animate({top:"+="+$(this).outerHeight()},{duration:animation_length,easing:"swing"});$("#site-container").animate({top:"+="+$(this).outerHeight()},{duration:animation_length,easing:"swing"})}})};