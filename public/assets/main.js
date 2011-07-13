$(function(){});$(function(){$(".audiobook-switcher a").tooltip({tip:".tooltip",effect:"fade",fadeOutSpeed:100,predelay:0,position:"bottom right",offset:[-25,5]})});function unique(a){var c=[],d=0;a:for(;d<a.length;d++){for(var f=0;f<c.length;f++)if(c[f]==a[d])continue a;c[c.length]=a[d]}return c}$(function(){$("ul.ui-autocomplete li.ui-menu-item:has('img')").each(function(){newHeight=$(this).find("img").height();$(this).height(newHeight+4)})});
var elementId="#term",apiUrl="http://6wfx.api.indextank.com",indexName="ClassiclyAutocomplete",source=apiUrl+"/v1/indexes/"+indexName+"/search",searchResults;
$.ui.autocomplete.prototype._renderItem=function(a,c){var d;d=c.type=="book"||c.type=="audiobook"?"<div class='with-cover'><img src='"+c.cover_url+"'class='micro-cover'><span class='text'>"+c.label+"<span class='type'>"+c.type+"</span></span></div>":c.label+"<span class='type'>"+c.type+"</span>";return $("<li></li>").data("item.autocomplete",c).append($("<a></a>").html(d)).appendTo(a)};
google.setOnLoadCallback(function(){$(function(){$(elementId).autocomplete({source:function(a,c){searchResults=[];$.ajax({url:apiUrl+"/v1/indexes/"+indexName+"/autocomplete",dataType:"jsonp",data:{query:a.term,field:"text"},success:function(a){$.ajax({url:source,dataType:"jsonp",data:{len:10,q:a.suggestions[0],snippet:"text",fetch:"text,type,slug,cover_url"},success:function(a){$.map(a.results,function(a){searchResults.push({label:a.snippet_text,value:a.text,type:a.type,slug:a.slug,cover_url:a.cover_url})});
c($.each(searchResults,function(a,d){return{label:d.label,value:d.value}}))}})}})},delay:250,select:function(a,c){a.target.value=c.item.value;window.location="http://classicly-staging.heroku.com"+c.item.slug}})})});
window.jQuery&&function(a){if(a.browser.msie)try{document.execCommand("BackgroundImageCache",!1,!0)}catch(c){}a.fn.rating=function(d){if(this.length==0)return this;if(typeof arguments[0]=="string"){if(this.length>1){var c=arguments;return this.each(function(){a.fn.rating.apply(a(this),c)})}a.fn.rating[arguments[0]].apply(this,a.makeArray(arguments).slice(1)||[]);return this}d=a.extend({},a.fn.rating.options,d||{});a.fn.rating.calls++;this.not(".star-rating-applied").addClass("star-rating-applied").each(function(){var b,
c=a(this),f=(this.name||"unnamed-rating").replace(/\[|\]/g,"_").replace(/^\_+|\_+$/g,""),j=a(this.form||document.body),h=j.data("rating");if(!h||h.call!=a.fn.rating.calls)h={count:0,call:a.fn.rating.calls};var i=h[f];i&&(b=i.data("rating"));if(i&&b)b.count++;else{b=a.extend({},d||{},(a.metadata?c.metadata():a.meta?c.data():null)||{},{count:0,stars:[],inputs:[]});b.serial=h.count++;i=a('<span class="star-rating-control"/>');c.before(i);i.addClass("rating-to-be-drawn");if(c.attr("disabled"))b.readOnly=
!0;i.append(b.cancel=a('<div class="rating-cancel"><a title="'+b.cancel+'">'+b.cancelValue+"</a></div>").mouseover(function(){a(this).rating("drain");a(this).addClass("star-rating-hover")}).mouseout(function(){a(this).rating("draw");a(this).removeClass("star-rating-hover")}).click(function(){a(this).rating("select")}).data("rating",b))}var e=a('<div class="star-rating rater-'+b.serial+'"><a title="'+(this.title||this.value)+'">'+this.value+"</a></div>");i.append(e);this.id&&e.attr("id",this.id);this.className&&
e.addClass(this.className);if(b.half)b.split=2;if(typeof b.split=="number"&&b.split>0){var g=(a.fn.width?e.width():0)||b.starWidth,m=b.count%b.split;g=Math.floor(g/b.split);e.width(g).find("a").css({"margin-left":"-"+m*g+"px"})}b.readOnly?e.addClass("star-rating-readonly"):e.addClass("star-rating-live").mouseover(function(){a(this).rating("fill");a(this).rating("focus")}).mouseout(function(){a(this).rating("draw");a(this).rating("blur")}).click(function(){a(this).rating("select")});if(this.checked)b.current=
e;c.hide();c.change(function(){a(this).rating("select")});e.data("rating.input",c.data("rating.star",e));b.stars[b.stars.length]=e[0];b.inputs[b.inputs.length]=c[0];b.rater=h[f]=i;b.context=j;c.data("rating",b);i.data("rating",b);e.data("rating",b);j.data("rating",h)});a(".rating-to-be-drawn").rating("draw").removeClass("rating-to-be-drawn");return this};a.extend(a.fn.rating,{calls:0,focus:function(){var d=this.data("rating");if(!d)return this;if(!d.focus)return this;var c=a(this).data("rating.input")||
a(this.tagName=="INPUT"?this:null);d.focus&&d.focus.apply(c[0],[c.val(),a("a",c.data("rating.star"))[0]])},blur:function(){var d=this.data("rating");if(!d)return this;if(!d.blur)return this;var c=a(this).data("rating.input")||a(this.tagName=="INPUT"?this:null);d.blur&&d.blur.apply(c[0],[c.val(),a("a",c.data("rating.star"))[0]])},fill:function(){var a=this.data("rating");if(!a)return this;a.readOnly||(this.rating("drain"),this.prevAll().andSelf().filter(".rater-"+a.serial).addClass("star-rating-hover"))},
drain:function(){var a=this.data("rating");if(!a)return this;a.readOnly||a.rater.children().filter(".rater-"+a.serial).removeClass("star-rating-on").removeClass("star-rating-hover")},draw:function(){var d=this.data("rating");if(!d)return this;this.rating("drain");d.current?(d.current.data("rating.input").attr("checked","checked"),d.current.prevAll().andSelf().filter(".rater-"+d.serial).addClass("star-rating-on")):a(d.inputs).removeAttr("checked");d.cancel[d.readOnly||d.required?"hide":"show"]();this.siblings()[d.readOnly?
"addClass":"removeClass"]("star-rating-readonly")},select:function(d,c){var b=this.data("rating");if(!b)return this;if(!b.readOnly){b.current=null;if(typeof d!="undefined"){if(typeof d=="number")return a(b.stars[d]).rating("select",void 0,c);typeof d=="string"&&a.each(b.stars,function(){a(this).data("rating.input").val()==d&&a(this).rating("select",void 0,c)})}else b.current=this[0].tagName=="INPUT"?this.data("rating.star"):this.is(".rater-"+b.serial)?this:null;this.data("rating",b);this.rating("draw");
var k=a(b.current?b.current.data("rating.input"):null);(c||c==void 0)&&b.callback&&b.callback.apply(k[0],[k.val(),a("a",b.current)[0]])}},readOnly:function(c,f){var b=this.data("rating");if(!b)return this;b.readOnly=c||c==void 0?!0:!1;f?a(b.inputs).attr("disabled","disabled"):a(b.inputs).removeAttr("disabled");this.data("rating",b);this.rating("draw")},disable:function(){this.rating("readOnly",!0,!0)},enable:function(){this.rating("readOnly",!1,!1)}});a.fn.rating.options={cancel:"Cancel Rating",cancelValue:"",
split:0,starWidth:16};a(function(){a("input[type=radio].star").rating()})}(jQuery);
(function(a){function c(h){var b=a('meta[name="csrf-token"]').attr("content");b&&h.setRequestHeader("X-CSRF-Token",b)}function d(h,b,c){b=new a.Event(b);h.trigger(b,c);return b.result!==!1}function f(b){var c,e,g,f=b.attr("data-type")||a.ajaxSettings&&a.ajaxSettings.dataType;if(b.is("form")){c=b.attr("method");e=b.attr("action");g=b.serializeArray();var j=b.data("ujs:submit-button");j&&(g.push(j),b.data("ujs:submit-button",null))}else c=b.attr("data-method"),e=b.attr("href"),g=null;a.ajax({url:e,
type:c||"GET",data:g,dataType:f,beforeSend:function(a,c){c.dataType===void 0&&a.setRequestHeader("accept","*/*;q=0.5, "+c.accepts.script);return d(b,"ajax:beforeSend",[a,c])},success:function(a,c,d){b.trigger("ajax:success",[a,c,d])},complete:function(a,c){b.trigger("ajax:complete",[a,c])},error:function(a,c,d){b.trigger("ajax:error",[a,c,d])}})}function b(b){b.find("input[data-disable-with]").each(function(){var b=a(this);b.data("ujs:enable-with",b.val()).val(b.attr("data-disable-with")).attr("disabled",
"disabled")})}function k(b){b.find("input[data-disable-with]").each(function(){var b=a(this);b.val(b.data("ujs:enable-with")).removeAttr("disabled")})}function l(a){var b=a.attr("data-confirm");return!b||d(a,"confirm")&&confirm(b)}function j(b){var c=!1;b.find("input[name][required]").each(function(){a(this).val()||(c=!0)});return c}"ajaxPrefilter"in a?a.ajaxPrefilter(function(a,b,d){c(d)}):a(document).ajaxSend(function(a,b){c(b)});a("a[data-confirm], a[data-method], a[data-remote]").live("click.rails",
function(){var b=a(this);if(!l(b))return!1;if(b.attr("data-remote")!=void 0)return f(b),!1;else if(b.attr("data-method")){var c=b.attr("href"),d=b.attr("data-method");b=a("meta[name=csrf-token]").attr("content");var g=a("meta[name=csrf-param]").attr("content");c=a('<form method="post" action="'+c+'"></form>');d='<input name="_method" value="'+d+'" type="hidden" />';g!==void 0&&b!==void 0&&(d+='<input name="'+g+'" value="'+b+'" type="hidden" />');c.hide().append(d).appendTo("body");c.submit();return!1}});
a("form").live("submit.rails",function(){var c=a(this),d=c.attr("data-remote")!=void 0;if(!l(c))return!1;if(j(c))return!d;if(d)return f(c),!1;else setTimeout(function(){b(c)},13)});a("form input[type=submit], form button[type=submit], form button:not([type])").live("click.rails",function(){var b=a(this);if(!l(b))return!1;var c=b.attr("name");c=c?{name:c,value:b.val()}:null;b.closest("form").data("ujs:submit-button",c)});a("form").live("ajax:beforeSend.rails",function(c){this==c.target&&b(a(this))});
a("form").live("ajax:complete.rails",function(b){this==b.target&&k(a(this))})})(jQuery);
