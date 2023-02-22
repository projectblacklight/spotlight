// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
import Spotlight from 'spotlight'

export default class {
  connect(){
    SirTrevor.setDefaults({
      iconUrl: Spotlight.sirTrevorIcon,
      uploadUrl: $('[data-attachment-endpoint]').data('attachment-endpoint'),
      ajaxOptions: {
        headers: {
          'X-CSRF-Token': Spotlight.csrfToken() || ''
        },
        credentials: 'same-origin'
      }
    });

    SirTrevor.Blocks.Heading.prototype.toolbarEnabled = true;
    SirTrevor.Blocks.Quote.prototype.toolbarEnabled = true;
    SirTrevor.Blocks.Text.prototype.toolbarEnabled = true;

    var instance = $('.js-st-instance').first();

    if (instance.length) {
      var editor = new SirTrevor.Editor({
        el: instance[0],
        blockTypes: instance.data('blockTypes'),
        defaultType:["Text"],
        onEditorRender: function() {
          $.SerializedForm();
        },
        blockTypeLimits: {
          "SearchResults": 1
        }
      });

      editor.blockControls = Spotlight.BlockControls.create(editor);

      new Spotlight.BlockLimits(editor).enforceLimits(editor);
    }
  }
}
