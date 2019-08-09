import React, {Component} from 'react'
import ReactDOM from 'react-dom'
import Editor, { Editable, createEmptyState }  from '@react-page/core';
import '@react-page/core/lib/index.css' // we also want to load the stylesheets
// Require our ui components (optional). You can implement and use your own ui too!
import { Trash, DisplayModeToggle, Toolbar } from '@react-page/ui'
import '@react-page/ui/lib/index.css'
import slate from '@react-page/plugins-slate' // The rich text area plugin
import '@react-page/plugins-slate/lib/index.css' // Stylesheets for the rich text area plugin

const editable = createEmptyState()
const editor = new Editor({
  plugins: {
    content: [slate()], // Define plugins for content cells. To import multiple plugins, use [slate(), image, spacer, divider]
  },
  defaultPlugin: slate(),
  editables: [editable]
});

editor.trigger.mode.edit();

class App extends Component {
  render() {
    return (
      <div>
        {/* Content area */}
        <Editable editor={editor} id={editable.id}/>

        {/*  Default user interface  */}
        <Trash editor={editor}/>
        <DisplayModeToggle editor={editor}/>
        <Toolbar editor={editor}/>
      </div>
    );
  }
}


$(document).ready( () => {
ReactDOM.render(
  <App />,
  document.getElementById('editable-1')
);
});
