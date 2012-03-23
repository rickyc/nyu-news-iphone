// Reset Font Size
var originalFontSize = $('html').css('font-size');

function reset(){
	$('html').css('font-size', originalFontSize);
};

// Increase Font Size
function increase() {
	var currentFontSize = $('html').css('font-size');
	var currentFontSizeNum = parseFloat(currentFontSize, 10);
	var newFontSize = currentFontSizeNum*1.1;
	$('html').css('font-size', newFontSize);
	$('.fixed').css('font-size', '1em');
};

// Decrease Font Size
function decrease() {
	var currentFontSize = $('html').css('font-size');
	var currentFontSizeNum = parseFloat(currentFontSize, 10);
	var newFontSize = currentFontSizeNum*0.9;
	$('html').css('font-size', newFontSize);
	$('.fixed').css('font-size', '1em');
};

$(document).ready(function(){
	$('#slideshow').cycle({ 
		fx:'fade', 
		speed:500 
	}); 
});