const merge = require('webpack-merge');
const common = require('./webpack.common.js');

module.exports = merge(common, {
  mode: 'production',
  watch: true,
  output: {
    filename: '[name].js',
    path: __dirname + '/dist'
  }
});
