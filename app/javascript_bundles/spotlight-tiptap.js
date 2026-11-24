// Entry point for the prebuilt Tiptap bundle (vendor/assets/javascripts/spotlight-tiptap.js).
// Tiptap and ProseMirror are bundled into a single file so that host applications
// load exactly one copy of each ProseMirror package (duplicates break the editor).
// Rebuild with `npm run prepare` after changing this file or upgrading Tiptap.
export { Editor, Mark, Node, Extension, mergeAttributes } from "@tiptap/core"
export { default as StarterKit } from "@tiptap/starter-kit"
export { TableKit } from "@tiptap/extension-table"
export { default as Image } from "@tiptap/extension-image"
