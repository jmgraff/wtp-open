const { VueLoaderPlugin } = require('vue-loader');
const CopyPlugin = require('copy-webpack-plugin');


module.exports = {
  entry: {
    background: './src/background.coffee',
    content: './src/content.coffee',
    popup: './src/popup.coffee',
    check: './src/check.js'
  },
  module: {
    rules: [
      {
        test: /\.(png|woff|woff2|eot|ttf|svg)$/,
        loader: 'url-loader'
      },
      {
        test: /\.vue$/,
        use: 'vue-loader'
      },
      {
        test: /\.pug$/,
        use: 'pug-plain-loader'
      },
      {
        test: /\.css$/,
        use: [
          'style-loader',
          'css-loader'
        ]
      },
      {
        test: /\.styl(us)?$/,
        use: [
          'vue-style-loader',
          'css-loader',
          'stylus-loader'
        ]
      },
      {
        test: /\.coffee$/,
        use: ['coffee-loader']
      }
    ]
  },
  plugins: [
    new VueLoaderPlugin(),
    new CopyPlugin([
      {from: './src/content-components/ContentScriptMenu.css', to: ''},
      {from: './src/manifest.json', to: ''},
      {from: './src/popup.html', to: ''},
      {from: './src/content.css', to: ''},
      {from: './src/images/Logo.png', to: 'images'}
    ])
  ]
}
