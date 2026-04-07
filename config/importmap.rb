# frozen_string_literal: true

pin_all_from File.expand_path('../app/javascript/spotlight', __dir__), under: 'spotlight'
pin_all_from File.expand_path('../vendor/assets/javascripts', __dir__)

pin 'clipboard', to: 'https://cdn.jsdelivr.net/npm/clipboard@2.0.11/+esm'
pin 'sir-trevor', to: 'https://cdn.jsdelivr.net/npm/sir-trevor@0.8.2/+esm'
pin 'sortablejs', to: 'https://cdn.jsdelivr.net/npm/sortablejs@^1.15.3/+esm'
pin '@github/auto-complete-element', to: 'https://cdn.jsdelivr.net/npm/@github/auto-complete-element@3.8.0/+esm'
pin '@editorjs/editorjs', to: 'https://esm.sh/@editorjs/editorjs@2.30.7'
pin '@editorjs/header', to: 'https://esm.sh/@editorjs/header@2.8.1'
pin '@phigoro/editorjs-toc', to: 'https://esm.sh/@phigoro/editorjs-toc@1.1.11'
