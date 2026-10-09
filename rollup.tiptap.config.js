import { nodeResolve } from "@rollup/plugin-node-resolve"
import terser from "@rollup/plugin-terser"

// Builds Tiptap (and ProseMirror) into one ES module that Spotlight loads on demand
// for the HTML page editor. See app/javascript_bundles/spotlight-tiptap.js
export default {
  input: "app/javascript_bundles/spotlight-tiptap.js",
  output: {
    file: "vendor/assets/javascripts/spotlight-tiptap.js",
    format: "es",
  },
  plugins: [nodeResolve(), terser({ format: { comments: "some" } })],
}
