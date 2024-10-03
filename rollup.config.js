'use strict'

import includePaths from 'rollup-plugin-includepaths';
import commonjs from '@rollup/plugin-commonjs';

const path = require('path')

const BUNDLE = process.env.BUNDLE === 'true'
const ESM = process.env.ESM === 'true'

const fileDest = `spotlight${ESM ? '.esm' : ''}`
const external = [
  'blacklight-frontend',
  'clipboard',
  'jquery-serializejson',
  'jquery',
  'leaflet',
  'sir-trevor'
]
const globals = {
  'blacklight-frontend': 'Blacklight',
  clipboard: 'Clipboard',
  jquery: 'jQuery',
  leaflet: 'L',
  'sir-trevor': 'SirTrevor'
}

let includePathOptions = {
  include: {},
  paths: ['app/javascript', 'vendor/assets/javascripts'],
  external: [],
  extensions: ['.js', '.es6']
};

const rollupConfig = {
  input: path.resolve(__dirname, `app/javascript/spotlight/index.js`),
  output: {
    file: path.resolve(__dirname, `app/assets/javascripts/spotlight/${fileDest}.js`),
    format: ESM ? 'esm' : 'umd',
    globals,
    generatedCode: 'es2015'
  },
  external,
  plugins: [includePaths(includePathOptions), commonjs()]
}

if (!ESM) {
  rollupConfig.output.name = 'Spotlight'
}

module.exports = rollupConfig