$(function(){});$(function(){$(".audiobook-switcher a").tooltip({tip:".tooltip",effect:"fade",fadeOutSpeed:100,predelay:0,position:"bottom right",offset:[-25,5]});$("#search #indexTankForm").submit(function(){var a=$(this).find("#term").val();_gaq&&_gaq.push(["_trackEvent","search_events","search",a])});$("#fb_connect_notification a#fb_decline").click(function(){$("#fb_connect_notification ").slideUp("slow");return!1});$(".pagination ul li.active").live("click",function(){return!1})});
function isLoggedIn(){var a=!1;FB.getLoginStatus(function(b){b.status=="connected"&&(a=!0)});return a}function sendKissMetricsEvent(a,b){_kmq&&(b?_kmq.push(["record",a,b]):_kmq.push(["record",a]))}function unique(a){var b=[],d=0;a:for(;d<a.length;d++){for(var e=0;e<b.length;e++)if(b[e]==a[d])continue a;b[b.length]=a[d]}return b}function compressText(a,b){a.length>b&&(a=a.substring(0,b-3),a+="...");return a}
function ssLess(a,b){var d=[];$("<div>"+a+"</div>").find("b").each(function(){d.push($(this).text())});var e=a.replace(/<.*?>/g,"");e=compressText(e,b);for(index in d)e=e.replace(d[index],"<b>"+d[index]+"</b>");return e}var elementId="#term",apiUrl="http://6wfx.api.indextank.com",indexName="ClassiclyAutocomplete",source=apiUrl+"/v1/indexes/"+indexName+"/search",searchResults;
$.ui.autocomplete.prototype._renderItem=function(a,b){var d;d=b.type=="book"||b.type=="audiobook"?"<div class='with-cover'><img src='"+b.cover_url+"'class='micro-cover'><span class='text'>"+ssLess(b.label,40)+"<span class='type'>"+b.type+"</span></span></div>":b.type=="collection"?b.label+"<span class='type'>"+b.type+"</span>":b.label;return $("<li></li>").data("item.autocomplete",b).append($("<a></a>").html(d)).appendTo(a)};
google.setOnLoadCallback(function(){$(function(){$(elementId).autocomplete({source:function(a,b){searchResults=[];$.ajax({url:apiUrl+"/v1/indexes/"+indexName+"/autocomplete",dataType:"jsonp",data:{query:a.term,field:"text"},success:function(d){$.ajax({url:source,dataType:"jsonp",data:{len:10,q:"("+d.suggestions[0]+") OR full:"+d.suggestions[0].replace(" ","")+"^100000",snippet:"text",fetch:"text,type,slug,cover_url"},success:function(d){$.map(d.results,function(a){searchResults.push({label:a.snippet_text,
value:a.text,type:a.type,slug:a.slug,cover_url:a.cover_url})});searchResults.push({label:"search <b>"+a.term+"</b>",value:a.term});b($.each(searchResults,function(a,d){return{label:d.label,value:d.value}}))}})}})},delay:250,select:function(a,b){a.target.value=b.item.value;b.item.slug!=void 0?window.location="http://www.classicly.com"+b.item.slug:$(a.target.form).submit()}})})});
window.jQuery&&function(a){if(a.browser.msie)try{document.execCommand("BackgroundImageCache",!1,!0)}catch(b){}a.fn.rating=function(d){if(this.length==0)return this;if(typeof arguments[0]=="string"){if(this.length>1){var b=arguments;return this.each(function(){a.fn.rating.apply(a(this),b)})}a.fn.rating[arguments[0]].apply(this,a.makeArray(arguments).slice(1)||[]);return this}d=a.extend({},a.fn.rating.options,d||{});a.fn.rating.calls++;this.not(".star-rating-applied").addClass("star-rating-applied").each(function(){var c,
b=a(this),e=(this.name||"unnamed-rating").replace(/\[|\]/g,"_").replace(/^\_+|\_+$/g,""),i=a(this.form||document.body),j=i.data("rating");if(!j||j.call!=a.fn.rating.calls)j={count:0,call:a.fn.rating.calls};var h=j[e];h&&(c=h.data("rating"));if(h&&c)c.count++;else{c=a.extend({},d||{},(a.metadata?b.metadata():a.meta?b.data():null)||{},{count:0,stars:[],inputs:[]});c.serial=j.count++;h=a('<span class="star-rating-control"/>');b.before(h);h.addClass("rating-to-be-drawn");if(b.attr("disabled"))c.readOnly=
!0;h.append(c.cancel=a('<div class="rating-cancel"><a title="'+c.cancel+'">'+c.cancelValue+"</a></div>").mouseover(function(){a(this).rating("drain");a(this).addClass("star-rating-hover")}).mouseout(function(){a(this).rating("draw");a(this).removeClass("star-rating-hover")}).click(function(){a(this).rating("select")}).data("rating",c))}var f=a('<div class="star-rating rater-'+c.serial+'"><a title="'+(this.title||this.value)+'">'+this.value+"</a></div>");h.append(f);this.id&&f.attr("id",this.id);this.className&&
f.addClass(this.className);if(c.half)c.split=2;if(typeof c.split=="number"&&c.split>0){var k=(a.fn.width?f.width():0)||c.starWidth,m=c.count%c.split;k=Math.floor(k/c.split);f.width(k).find("a").css({"margin-left":"-"+m*k+"px"})}c.readOnly?f.addClass("star-rating-readonly"):f.addClass("star-rating-live").mouseover(function(){a(this).rating("fill");a(this).rating("focus")}).mouseout(function(){a(this).rating("draw");a(this).rating("blur")}).click(function(){a(this).rating("select")});if(this.checked)c.current=
f;b.hide();b.change(function(){a(this).rating("select")});f.data("rating.input",b.data("rating.star",f));c.stars[c.stars.length]=f[0];c.inputs[c.inputs.length]=b[0];c.rater=j[e]=h;c.context=i;b.data("rating",c);h.data("rating",c);f.data("rating",c);i.data("rating",j)});a(".rating-to-be-drawn").rating("draw").removeClass("rating-to-be-drawn");return this};a.extend(a.fn.rating,{calls:0,focus:function(){var d=this.data("rating");if(!d)return this;if(!d.focus)return this;var b=a(this).data("rating.input")||
a(this.tagName=="INPUT"?this:null);d.focus&&d.focus.apply(b[0],[b.val(),a("a",b.data("rating.star"))[0]])},blur:function(){var d=this.data("rating");if(!d)return this;if(!d.blur)return this;var b=a(this).data("rating.input")||a(this.tagName=="INPUT"?this:null);d.blur&&d.blur.apply(b[0],[b.val(),a("a",b.data("rating.star"))[0]])},fill:function(){var a=this.data("rating");if(!a)return this;a.readOnly||(this.rating("drain"),this.prevAll().andSelf().filter(".rater-"+a.serial).addClass("star-rating-hover"))},
drain:function(){var a=this.data("rating");if(!a)return this;a.readOnly||a.rater.children().filter(".rater-"+a.serial).removeClass("star-rating-on").removeClass("star-rating-hover")},draw:function(){var b=this.data("rating");if(!b)return this;this.rating("drain");b.current?(b.current.data("rating.input").attr("checked","checked"),b.current.prevAll().andSelf().filter(".rater-"+b.serial).addClass("star-rating-on")):a(b.inputs).removeAttr("checked");b.cancel[b.readOnly||b.required?"hide":"show"]();this.siblings()[b.readOnly?
"addClass":"removeClass"]("star-rating-readonly")},select:function(b,e){var c=this.data("rating");if(!c)return this;if(!c.readOnly){c.current=null;if(typeof b!="undefined"){if(typeof b=="number")return a(c.stars[b]).rating("select",void 0,e);typeof b=="string"&&a.each(c.stars,function(){a(this).data("rating.input").val()==b&&a(this).rating("select",void 0,e)})}else c.current=this[0].tagName=="INPUT"?this.data("rating.star"):this.is(".rater-"+c.serial)?this:null;this.data("rating",c);this.rating("draw");
var g=a(c.current?c.current.data("rating.input"):null);(e||e==void 0)&&c.callback&&c.callback.apply(g[0],[g.val(),a("a",c.current)[0]])}},readOnly:function(b,e){var c=this.data("rating");if(!c)return this;c.readOnly=b||b==void 0?!0:!1;e?a(c.inputs).attr("disabled","disabled"):a(c.inputs).removeAttr("disabled");this.data("rating",c);this.rating("draw")},disable:function(){this.rating("readOnly",!0,!0)},enable:function(){this.rating("readOnly",!1,!1)}});a.fn.rating.options={cancel:"Cancel Rating",cancelValue:"",
split:0,starWidth:16};a(function(){a("input[type=radio].star").rating()})}(jQuery);
(function(a){function b(b){var c=a('meta[name="csrf-token"]').attr("content");c&&b.setRequestHeader("X-CSRF-Token",c)}function d(b,c,d){c=new a.Event(c);b.trigger(c,d);return c.result!==!1}function e(b){var c,f,e,i=b.attr("data-type")||a.ajaxSettings&&a.ajaxSettings.dataType;if(b.is("form")){c=b.attr("method");f=b.attr("action");e=b.serializeArray();var g=b.data("ujs:submit-button");g&&(e.push(g),b.data("ujs:submit-button",null))}else c=b.attr("data-method"),f=b.attr("href"),e=null;a.ajax({url:f,
type:c||"GET",data:e,dataType:i,beforeSend:function(a,c){c.dataType===void 0&&a.setRequestHeader("accept","*/*;q=0.5, "+c.accepts.script);return d(b,"ajax:beforeSend",[a,c])},success:function(a,c,d){b.trigger("ajax:success",[a,c,d])},complete:function(a,c){b.trigger("ajax:complete",[a,c])},error:function(a,c,d){b.trigger("ajax:error",[a,c,d])}})}function c(b){b.find("input[data-disable-with]").each(function(){var b=a(this);b.data("ujs:enable-with",b.val()).val(b.attr("data-disable-with")).attr("disabled",
"disabled")})}function g(b){b.find("input[data-disable-with]").each(function(){var b=a(this);b.val(b.data("ujs:enable-with")).removeAttr("disabled")})}function l(a){var b=a.attr("data-confirm");return!b||d(a,"confirm")&&confirm(b)}function i(b){var c=!1;b.find("input[name][required]").each(function(){a(this).val()||(c=!0)});return c}"ajaxPrefilter"in a?a.ajaxPrefilter(function(a,c,d){b(d)}):a(document).ajaxSend(function(a,c){b(c)});a("a[data-confirm], a[data-method], a[data-remote]").live("click.rails",
function(){var b=a(this);if(!l(b))return!1;if(b.attr("data-remote")!=void 0)return e(b),!1;else if(b.attr("data-method")){var c=b.attr("href"),d=b.attr("data-method");b=a("meta[name=csrf-token]").attr("content");var g=a("meta[name=csrf-param]").attr("content");c=a('<form method="post" action="'+c+'"></form>');d='<input name="_method" value="'+d+'" type="hidden" />';g!==void 0&&b!==void 0&&(d+='<input name="'+g+'" value="'+b+'" type="hidden" />');c.hide().append(d).appendTo("body");c.submit();return!1}});
a("form").live("submit.rails",function(){var b=a(this),d=b.attr("data-remote")!=void 0;if(!l(b))return!1;if(i(b))return!d;if(d)return e(b),!1;else setTimeout(function(){c(b)},13)});a("form input[type=submit], form button[type=submit], form button:not([type])").live("click.rails",function(){var b=a(this);if(!l(b))return!1;var c=b.attr("name");c=c?{name:c,value:b.val()}:null;b.closest("form").data("ujs:submit-button",c)});a("form").live("ajax:beforeSend.rails",function(b){this==b.target&&c(a(this))});
a("form").live("ajax:complete.rails",function(b){this==b.target&&g(a(this))})})(jQuery);function hideGlobalNotifications(a){$(".global-notification").each(function(){var b=0;a&&(b=500);$(this).is(":visible")&&($(this).animate({top:"-="+$(this).outerHeight()},{duration:b,easing:"swing",complete:function(){$(this).hide()}}),$("#site-container").animate({top:"-="+$(this).outerHeight()},{duration:b,easing:"swing"}))})}
function showGlobalNotifications(){$(".global-notification").each(function(){animation_length=500;$(this).is(":visible")||($(this).show(),$(this).animate({top:"+="+$(this).outerHeight()},{duration:animation_length,easing:"swing"}),$("#site-container").animate({top:"+="+$(this).outerHeight()},{duration:animation_length,easing:"swing"}))})};
