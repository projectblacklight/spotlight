// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
import Core from 'spotlight/core'
import { SerializedForm } from 'spotlight/admin/form_observer'

export default class {
  connect(){
    var attachmentEndpointEl = document.querySelector('[data-attachment-endpoint]')
    SirTrevor.setDefaults({
      iconUrl: Spotlight.sirTrevorIcon,
      uploadUrl: attachmentEndpointEl ? attachmentEndpointEl.dataset.attachmentEndpoint : undefined,
      ajaxOptions: {
        headers: {
          'X-CSRF-Token': Core.csrfToken() || ''
        },
        credentials: 'same-origin'
      }
    });

    SirTrevor.Blocks.Heading.prototype.toolbarEnabled = true;
    SirTrevor.Blocks.Quote.prototype.toolbarEnabled = true;
    SirTrevor.Blocks.Text.prototype.toolbarEnabled = true;

    var instance = document.querySelector('.js-st-instance');

    if (instance) {
      var editor = new SirTrevor.Editor({
        el: instance,
        blockTypes: JSON.parse(instance.dataset.blockTypes),
        altTextSettings: JSON.parse(instance.dataset.altTextSettings),
        defaultType:["Text"],
        onEditorRender: function() {
          SerializedForm.init();
        },
        blockTypeLimits: {
          "SearchResults": 1
        }
      });

      editor.blockControls = Core.BlockControls.create(editor);

      new Core.BlockLimits(editor).enforceLimits(editor);
    }
  }
}
