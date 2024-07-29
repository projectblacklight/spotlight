# frozen_string_literal: true

# pin_all_from File.expand_path('../app/javascript/spotlight', __dir__), under: 'spotlight'
# pin_all_from File.expand_path('../vendor/assets/javascripts', __dir__)
pin 'spotlight/spotlight.esm', to: 'spotlight/spotlight.esm.js', preload: true
pin 'sir-trevor', to: 'sir-trevor.js'
pin 'leaflet-iiif', to: 'leaflet-iiif.esm.js'
