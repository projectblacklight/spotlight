export default class {
  connect() {
    var $clearBtn = $('.btn-reset');
    var $input = $clearBtn.prev('#browse_q');
    var btnCheck = function(){
      if ($input.val() !== '') {
        $clearBtn.css('display', 'block');
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
  }
}
