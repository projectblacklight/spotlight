import EditorJS from '@editorjs/editorjs';
import Delimiter from '@editorjs/delimiter';
import Image from '@editorjs/image';
import List from '@editorjs/list';
import Quote from '@editorjs/quote';
import Raw from '@editorjs/raw';
import Underline from '@editorjs/underline';

export default function(formControl = '.js-editorjs-instance') {
  Spotlight.onLoad(function(){
    console.log('Hello World from editor init');
    var editorjsinstance = $(formControl).first();

    if (editorjsinstance.length) {
      $('<div id="codex-editor"></div>').insertAfter(editorjsinstance);
      const data = JSON.parse($(editorjsinstance).val());

      const editor = new EditorJS({
        /**
         * Id of Element that should contain the Editor
         */
        holder: 'codex-editor',

        /**
         * Previously saved data that should be rendered
         */
        data: data['data'] || {},
        tools: {
          delimiter: Delimiter,
          image: Image,
          list: {
            class: List,
            inlineToolbar: true,
          },
          quote: {
            class: Quote,
            inlineToolbar: true,
          },
          raw: Raw,
          underline: Underline,
        }
      });

      $(editorjsinstance).closest('form').on('submit', async function() {
        await editor.save().then(function(outputData) {
          $(editorjsinstance).val(JSON.stringify(outputData));
        });
      });
    }
  });
}
