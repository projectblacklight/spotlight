// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
Spotlight.onLoad(function(){

  SirTrevor.setDefaults({
    uploadUrl: $('[data-attachment-endpoint]').data('attachment-endpoint')
  });

  var instance = $('.sir-trevor-area').first();

  if (instance.length) {

    SirTrevor.EventBus.on('block:create:new', injectElementsIntoSirTrevorBlock);
    SirTrevor.EventBus.on('block:create:existing', injectElementsIntoSirTrevorBlock);

    SirTrevor.EventBus.on('block:create:new', checkBlockTypeLimitOnAdd);
    SirTrevor.EventBus.on('block:remove', checkGlobalBlockTypeLimit);

    var editor = new SirTrevor.Editor({
      el: instance,
      onEditorRender: function() {
        serializeObservedForms(observedForms());
      },
      blockTypeLimits: {
        "SearchResults": 1,
        "Tweet": -1
      }
    });

    function checkBlockTypeLimitOnAdd(block) {
      var control = editor.$outer.find("a[data-type='" + block.blockCSSClass() + "']");

      control.toggleClass("disabled", !editor._canAddBlockType(block.class()));
    }

    function checkGlobalBlockTypeLimit() {
      // we don't know what type of block was created or removed.. So, try them all.

      $.each(editor.blockTypes, function(type) {
        var control = editor.$outer.find(".st-block-control[data-type='" + _.underscored(type) + "']");
        if (editor._getBlockTypeLimit(type) < 0) {
          control.remove();
        } else {
          control.toggleClass("disabled", !editor._canAddBlockType(type));
        }
      });
    }

    checkGlobalBlockTypeLimit();
  }
});

function injectElementsIntoSirTrevorBlock(block) {
  addTitleToSirTrevorBlock(block);
  addPreviewToSirTrevorBlock(block);
};

function addTitleToSirTrevorBlock(block){
  block.$inner.append("<div class='st-title'>" + block.title() + "</div>");
};

function addPreviewToSirTrevorBlock(block){
  var preview = $('<button class="st-block-ui-btn preview-btn">Preview</button>');

  preview.on('click', function(event) {
    event.stopPropagation();
    var preview_btn = $(this);
    preview_btn.attr('disabled', 'disabled');

    block.saveAndGetData();

    $.post($(this).closest('form').data('preview-url'), {block: JSON.stringify(block.blockStorage) },
      function(preview) {
        var btn = $('<button class="st-block-ui-btn preview-exit-btn">Edit</button>').click(function(event) {
          event.stopPropagation();
          block.$inner.show();
          $(this).closest('.preview').remove();
          preview_btn.removeAttr('disabled');
        });

        var widget_bar = $('<div class="st-block__ui" />').append(btn);

        $('<div class="preview clearfix st-block__inner">').append(preview).append(widget_bar).insertAfter(block.$inner);
          block.$inner.hide();
        }
      );
  });

  block.$inner.find('.st-block__ui').prepend(preview);
};
