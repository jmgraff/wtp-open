const merge = require('webpack-merge');
const common = require('./webpack.common.js');

const ChromeExtensionReloader = require('webpack-chrome-extension-reloader');

module.exports = merge(common, {

  mode: 'development',
  devtool: 'source-map',
  watch: true,
  output: {
    filename: '[name].js',
    path: __dirname + '/dev'
  },
  plugins: [
    new ChromeExtensionReloader()
  ]
});
