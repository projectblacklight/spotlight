'use strict'

import includePaths from 'rollup-plugin-includepaths';
import resolve from '@rollup/plugin-node-resolve';

const path = require('path')

const BUNDLE = process.env.BUNDLE === 'true'
const ESM = process.env.ESM === 'true'

const fileDest = `spotlight${ESM ? '.esm' : ''}`
const external = []
const globals = {}

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
  plugins: [
    resolve(),
    includePaths(includePathOptions)
  ]
}

if (!ESM) {
  rollupConfig.output.name = 'Spotlight'
}

module.exports = rollupConfig