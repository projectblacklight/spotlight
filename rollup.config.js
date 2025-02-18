import includePaths from 'rollup-plugin-includepaths';
import commonjs from '@rollup/plugin-commonjs';

const BUNDLE = process.env.BUNDLE === 'true'
const ESM = process.env.ESM === 'true'

const fileDest = `spotlight${ESM ? '.esm' : ''}`
const external = [
  '@github/auto-complete-element',
  '@hotwired/stimulus',
  'blacklight-frontend',
  'clipboard',
  'jquery-serializejson',
  'jquery',
  'leaflet',
  'openseadragon',
  'sir-trevor',
  'sortablejs'
]
const globals = {
  '@github/auto-complete-element': 'AutoCompleteElement',
  '@hotwired/stimulus': 'Stimulus',
  'blacklight-frontend': 'Blacklight',
  clipboard: 'Clipboard',
  jquery: 'jQuery',
  leaflet: 'L',
  openseadragon: 'OpenSeadragon',
  'sir-trevor': 'SirTrevor',
  'sortablejs': 'Sortable'
}
let includePathOptions = {
  include: {},
  paths: ['app/javascript', 'app/javascript/controllers', 'vendor/assets/javascripts'],
  external: [],
  extensions: ['.js', '.es6']
};

const rollupConfig = {
  input: 'app/javascript/spotlight/index.js',
  output: {
    file: `app/assets/javascripts/spotlight/${fileDest}.js`,
    format: ESM ? 'es' : 'umd',
    globals,
    generatedCode: { preset: 'es2015' },
    name: ESM ? undefined : 'Spotlight'
  },
  external,
  plugins: [includePaths(includePathOptions), commonjs()]
}

export default rollupConfig