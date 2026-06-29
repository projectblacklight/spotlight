import js from "@eslint/js";
import globals from "globals";

export default [
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: {
        ...globals.browser,
        ...globals.jquery,
        Blacklight: "readonly",
        Spotlight: "readonly",
        URLify: "readonly",
        sirTrevorIcon: "readonly",
        SirTrevor: "readonly",
        Stimulus: "readonly",
        L: "readonly",
        i18n: "readonly",
        stToMarkdown: "readonly",
        webkitURL: "readonly",
      },
    },
    rules: {
      "max-len": [
        "error",
        {
          code: 120,
          ignoreStrings: true,
          ignoreTemplateLiterals: true,
          ignoreUrls: true,
          ignoreComments: true,
        },
      ],
      "no-unused-vars": [
        "error",
        {
          args: "after-used",
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
        },
      ],
    },
    ignores: [
      "node_modules/",
      "vendor/",
      "coverage/",
      ".internal_test_app/",
      "pkg/",
      "app/assets/javascripts/",
      "**/*.min.js",
      "rollup.config.js",
    ],
  },
];
