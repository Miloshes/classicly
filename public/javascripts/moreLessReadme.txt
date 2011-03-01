Name:       More/Less Text Collapser

Version:    1.0 (February 22th, 2010)

Author:     Adam C. Miller

==================================================================================
Licence:
==================================================================================
More/Less Text Collapser is licensed under the MIT license

http://www.opensource.org/licenses/mit-license.php
            
==================================================================================
About:
==================================================================================
More/Less Text Collapser is a simple jQuery plugin to add more/less controls to a portion of text in your html. It will truncate your text at a secified point and add a control to show or hide the truncted content.


Main Features:
--------------

    * Collapse large blocks of text into a few lines with a '...more' link to expand the text.
    * Searches within a range to find a character to start hiding content.
    * Can specify callback function.
    * Can override animation speed.
    * Can override animation speed.
    * Can specify minimum length to allow truncating.


Usage:
----------------
Default options:
----------------

<div class="myContent">
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer eleifend enim convallis quam dictum tristique. Aliquam erat volutpat. Mauris sagittis ornare mauris et sollicitudin. Aenean cursus laoreet justo ac eleifend. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce lacus ante, tristique sit amet facilisis ut, malesuada ut libero. Integer molestie nunc vitae felis faucibus in laoreet dui malesuada. Fusce sollicitudin viverra arcu, non imperdiet mauris rutrum id. Nunc blandit urna et erat rhoncus convallis. Donec vitae magna non orci porttitor placerat vitae vitae neque. Ut quis leo orci, eu euismod est. Pellentesque augue risus, commodo pulvinar cursus ac, aliquet non ante. Nam viverra vulputate mauris a accumsan.
<br /><br />
Aliquam sed diam urna. Maecenas id ligula lectus. Sed sagittis, libero aliquam dictum venenatis, ligula augue vulputate sapien, in adipiscing risus eros a elit. Cras in volutpat ante. Nam viverra ornare ultricies. Morbi fringilla orci id purus laoreet tempus a quis enim. Curabitur at urna odio. Aenean ultrices augue sit amet ante posuere egestas. Nunc fringilla lorem ac magna ornare venenatis et nec neque. Etiam sit amet massa diam. Suspendisse tortor ligula, egestas sed tempus eu, pulvinar id sapien. Vestibulum nec condimentum metus. Donec eleifend auctor consequat. In id ipsum vitae nisl ornare semper. Aliquam erat volutpat. Aliquam pharetra gravida dui, tristique tempor justo sollicitudin vel. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
</div>
<script type="text/javascript">
    $('.myContent').moreLess();
</script>

Usage:
--------------------------------------------------------------------
Slow animation, begin collapsing at 200 characters and use callback:
--------------------------------------------------------------------
$('.myContent').moreLess({
     speed:'slow',
     callback: function(){alert('done');}
});


Options:
--------

Options

    * startExpanded: Whether text starts expanded or collapsed. Default(false)
    * collapsedText: Expander control. Default('... More')
    * expandedText: Collapser control. Default('Less...')
    * truncateIndex: Minimum index to begin collapsing the text. Default(150)
    * maximumTruncateIndex: Maximum index to begin collapsing the text. Default(200)
    * truncateChar: Character to search for to begin collapsing the text at. Default(' ')
    * minimumTextLength: Minimum content length necessary to allow collapsing of text. Default(300)
    * speed: Collapse/Expand animation speed. Default('fast')
    * callback: Callback function to execute after Collapse/Expand animation has completed.Default(null)



Files:
------
 css/
	moreLess.css - Style Sheet for More/Less Text Collapser

 javascript/
	jquery.moreless.1.0.js (2.80KB)
	jquery.moreLess.1.0.min.js (1.42KB)
	

==================================================================================
Change Log:
==================================================================================


Version 1.0 (February 22th, 2010)
 - Initial Release

