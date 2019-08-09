Spotlight.onLoad(function() {
  $('.btn-reset').ClearFormButton();
});

(function($) {
  $.fn.ClearFormButton = function() {
    var $clearBtn = $(this);
    var $input = $clearBtn.parent().prev('input');
    var btnCheck = function(){
      if ($input.val() !== '') {
        $clearBtn.css('display', 'inline-block');
      } else {
        $clearBtn.css('display', 'none');
      }
    };

    btnCheck();
    $input.on('keyup', function() {
      btnCheck();
    });

    $clearBtn.on('click', function(event) {
      event.preventDefault();
      $input.val('');
    });
  };
})(jQuery);
