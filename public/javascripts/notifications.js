function hideGlobalNotifications(animate) {
	$('.global-notification').each( function() {		
		var animation_length = 0;
		
		if (animate) {
			animation_length = 500;
		}
		
		if ( $(this).is(':visible') ) {
				$(this).animate({'top': '-=' + $(this).css('height')}, animation_length, function() { $(this).hide(); });
		}
	});
}

function showGlobalNotifications() {
	$('.global-notification').each( function() {
		// if it's not visible, animate it in
		if ( !$(this).is(':visible') ) {
			$(this).show();
			$(this).animate({'top': '+=' + $(this).css('height')}, 500);
		}
	});
}