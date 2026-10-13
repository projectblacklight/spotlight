// WYSIWYG (Tiptap) editor for pages whose content_type is "Html".
// SirTrevor pages are handled separately by spotlight/admin/pages.
//
// Tiptap is loaded on demand from the prebuilt "spotlight-tiptap" bundle,
// so it is only downloaded when an HTML page is being edited.
import { SerializedForm } from "spotlight/admin/form_observer"

const TOOLBAR_GROUPS = [
  [
    {
      name: "bold",
      text: "B",
      run: (c) => c.toggleBold(),
      active: (e) => e.isActive("bold"),
    },
    {
      name: "italic",
      text: "I",
      run: (c) => c.toggleItalic(),
      active: (e) => e.isActive("italic"),
    },
    {
      name: "underline",
      text: "U",
      run: (c) => c.toggleUnderline(),
      active: (e) => e.isActive("underline"),
    },
    {
      name: "strike",
      text: "S",
      run: (c) => c.toggleStrike(),
      active: (e) => e.isActive("strike"),
    },
  ],
  [2, 3, 4].map((level) => ({
    name: `heading${level}`,
    text: `H${level}`,
    run: (c) => c.toggleHeading({ level }),
    active: (e) => e.isActive("heading", { level }),
  })),
  [
    {
      name: "bullet_list",
      text: "•",
      run: (c) => c.toggleBulletList(),
      active: (e) => e.isActive("bulletList"),
    },
    {
      name: "ordered_list",
      text: "1.",
      run: (c) => c.toggleOrderedList(),
      active: (e) => e.isActive("orderedList"),
    },
    {
      name: "blockquote",
      text: "“”",
      run: (c) => c.toggleBlockquote(),
      active: (e) => e.isActive("blockquote"),
    },
    {
      name: "horizontal_rule",
      text: "—",
      run: (c) => c.setHorizontalRule(),
    },
  ],
  [
    {
      name: "link",
      text: "🔗",
      prompt: "link_prompt",
      run: (c, url) =>
        url
          ? c.extendMarkRange("link").setLink({ href: url })
          : c.extendMarkRange("link").unsetLink(),
      active: (e) => e.isActive("link"),
    },
  ],
  [
    {
      name: "insert_table",
      text: "⊞",
      run: (c) => c.insertTable({ rows: 3, cols: 3, withHeaderRow: true }),
    },
    { name: "add_row", text: "+row", run: (c) => c.addRowAfter() },
    { name: "add_column", text: "+col", run: (c) => c.addColumnAfter() },
    { name: "delete_row", text: "−row", run: (c) => c.deleteRow() },
    { name: "delete_column", text: "−col", run: (c) => c.deleteColumn() },
    { name: "delete_table", text: "✕⊞", run: (c) => c.deleteTable() },
  ],
  [
    { name: "undo", text: "↶", run: (c) => c.undo() },
    { name: "redo", text: "↷", run: (c) => c.redo() },
  ],
]

function buildToolbar(labels) {
  const toolbar = document.createElement("div")
  toolbar.className = "html-editor-toolbar btn-toolbar mb-2"
  toolbar.setAttribute("role", "toolbar")
  toolbar.setAttribute("aria-label", labels.toolbar || "Formatting")

  const buttons = []
  TOOLBAR_GROUPS.forEach((group) => {
    const groupEl = document.createElement("div")
    groupEl.className = "btn-group btn-group-sm me-2 mb-1"
    groupEl.setAttribute("role", "group")
    group.forEach((definition) => {
      const button = document.createElement("button")
      button.type = "button"
      button.className = "btn btn-outline-secondary"
      button.textContent = definition.text
      button.title = labels[definition.name] || definition.name
      button.setAttribute("aria-label", button.title)
      button.dataset.command = definition.name
      button.tabIndex = buttons.length === 0 ? 0 : -1
      groupEl.appendChild(button)
      buttons.push({ button, definition })
    })
    toolbar.appendChild(groupEl)
  })

  // Toolbar keyboard pattern: one tab stop, arrow keys move between buttons
  toolbar.addEventListener("keydown", (event) => {
    if (!["ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) return
    const enabled = buttons.map((b) => b.button).filter((b) => !b.disabled)
    const index = enabled.indexOf(document.activeElement)
    let next
    if (event.key === "Home") next = 0
    else if (event.key === "End") next = enabled.length - 1
    else
      next =
        (index + (event.key === "ArrowRight" ? 1 : -1) + enabled.length) %
        enabled.length
    enabled.forEach((b) => (b.tabIndex = -1))
    enabled[next].tabIndex = 0
    enabled[next].focus()
    event.preventDefault()
  })

  return { toolbar, buttons }
}

function refreshToolbar(editor, buttons) {
  buttons.forEach(({ button, definition }) => {
    const can = definition.run(editor.can().chain().focus(), "x").run()
    button.disabled = !can && !definition.prompt
    if (definition.active) {
      const active = definition.active(editor)
      button.classList.toggle("active", active)
      button.setAttribute("aria-pressed", active ? "true" : "false")
    }
  })
}

// StarterKit's TrailingNode keeps an empty paragraph at the end of the document
// (so there is always somewhere to type); don't save it.
function serialize(editor) {
  return editor.getHTML().replace(/(<p><\/p>)+$/, "")
}

export function mountHtmlEditor(textarea, tiptap) {
  const { Editor, StarterKit, TableKit } = tiptap
  const labels = JSON.parse(textarea.dataset.editorLabels || "{}")

  const wrapper = document.createElement("div")
  wrapper.className = "html-editor"
  const { toolbar, buttons } = buildToolbar(labels)
  const content = document.createElement("div")
  content.className = "html-editor-content form-control"
  wrapper.append(toolbar, content)
  textarea.after(wrapper)
  textarea.hidden = true

  const editor = new Editor({
    element: content,
    content: textarea.value,
    extensions: [
      StarterKit.configure({
        heading: { levels: [2, 3, 4] },
        link: {
          openOnClick: false,
          defaultProtocol: "https",
          protocols: ["http", "https", "mailto"],
        },
      }),
      TableKit.configure({ table: { resizable: false } }),
    ],
    editorProps: {
      attributes: {
        "aria-label": labels.content || "Page content",
        "aria-multiline": "true",
        role: "textbox",
      },
    },
    onUpdate: ({ editor }) => {
      textarea.value = serialize(editor)
    },
    onTransaction: ({ editor }) => refreshToolbar(editor, buttons),
  })

  buttons.forEach(({ button, definition }) => {
    button.addEventListener("click", () => {
      let value
      if (definition.prompt) {
        value = window.prompt(
          labels[definition.prompt] || "URL",
          editor.getAttributes("link").href || "",
        )
        if (value === null) return
      }
      definition.run(editor.chain().focus(), value).run()
    })
  })

  // Normalize the stored HTML to what Tiptap produces, then snapshot the form
  // so the unsaved-changes warning doesn't fire for an untouched page.
  textarea.value = serialize(editor)
  refreshToolbar(editor, buttons)
  SerializedForm.init()

  return editor
}

export default class {
  connect() {
    const textareas = document.querySelectorAll(".js-html-instance")
    if (textareas.length === 0) return

    return import("spotlight-tiptap").then((tiptap) => {
      textareas.forEach((textarea) => {
        if (textarea.dataset.htmlEditorMounted) return
        textarea.dataset.htmlEditorMounted = "true"
        mountHtmlEditor(textarea, tiptap)
      })
    })
  }
}
