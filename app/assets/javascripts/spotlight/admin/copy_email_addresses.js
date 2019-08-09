(function($) {
    $.fn.copyEmailAddresses = function( options ) {
        var clip = new Clipboard('.copy-email-addresses');
    };
})( jQuery );

Spotlight.onLoad(function() {
    $('.copy-email-addresses').copyEmailAddresses();
});
