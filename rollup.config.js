'use strict'

import includePaths from 'rollup-plugin-includepaths';
import globals from 'rollup-plugin-external-globals';

const path = require('path')

const BUNDLE = process.env.BUNDLE === 'true'
const ESM = process.env.ESM === 'true'

const fileDest = `spotlight${ESM ? '.esm' : ''}`
const external = [
  'clipboard',
  'leaflet-iiif',
  'jquery',
]
const outputGlobals = {
  'clipboard': 'Clipboard',
  'jquery': '$',
}

let includePathOptions = {
  include: {},
  paths: ['app/javascript', 'vendor/assets/javascripts'],
  external: [],
  extensions: ['.js', '.es6']
};

const globalsPluginOptions = {
  'jquery': '$',
};

const rollupConfig = {
  input: path.resolve(__dirname, `app/javascript/spotlight/index.js`),
  output: {
    file: path.resolve(__dirname, `app/assets/javascripts/spotlight/${fileDest}.js`),
    format: ESM ? 'esm' : 'umd',
    globals: outputGlobals,
    generatedCode: 'es2015'
  },
  external,
  plugins: [
    includePaths(includePathOptions),
    globals(globalsPluginOptions)
  ]
}

if (!ESM) {
  rollupConfig.output.name = 'Spotlight'
}

module.exports = rollupConfig