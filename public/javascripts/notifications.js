// call it with animate=true if you want it to animate
function hideGlobalNotifications(animate) {
	$('.global-notification').each( function() {		
		var animation_length = 0;
		
		if (animate) {
			animation_length = 500;
		}
		
		if ( $(this).is(':visible') ) {
			$(this).animate(
				{
					'top': '-=' + $(this).outerHeight()
				},
				{
					duration: animation_length,
			    easing: 'swing',
					complete: function() { $(this).hide(); }
				}
			);
			$('#site-container').animate(
				{
					'top': '-=' + $(this).outerHeight()
				},
				{
					duration: animation_length,
					easing: 'swing'
				}
			);
		}
	});
}

function showGlobalNotifications() {
	$('.global-notification').each( function() {
		
		animation_length = 500;
		
		// if it's not visible, animate it in
		if ( !$(this).is(':visible') ) {
			$(this).show();
			$(this).animate(
				{
					'top': '+=' + $(this).outerHeight()
				},
				{
					duration: animation_length,
			    easing: 'swing'
				}
			);
			$('#site-container').animate(
				{
					'top': '+=' + $(this).outerHeight()
				},
				{
					duration: animation_length,
					easing: 'swing'
				}
			);
		}
	});
}