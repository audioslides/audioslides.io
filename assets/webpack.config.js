const path = require('path');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => ({
  entry: './js/app.js',
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, '../priv/static/js')
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.scss$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: [{
            loader: 'css-loader',
            options: {
              minimize: options.mode === 'production'
            }
          },
          {
            loader: 'sass-loader',
            options: {
              sourceMap: true,
              includePaths: [
                path.resolve(__dirname, 'node_modules/bootstrap/scss'),
                path.resolve(__dirname, 'node_modules/font-awesome/scss')
              ]
            }
          }
          ]
        })
      }
    ]
  },
  plugins: [
    new ExtractTextPlugin('../css/app.css'),
    new CopyWebpackPlugin([{ from: 'static/', to: '../' }])
  ]
});
