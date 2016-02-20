path = require 'path'
merge = require 'webpack-merge'
webpack = require 'webpack'
NpmInstallPlugin = require 'npm-install-webpack-plugin'
stylelint = require 'stylelint'

TARGET = process.env.npm_lifecycle_event
PATHS =
  app: path.join(__dirname, 'app')
  build: path.join(__dirname, 'build')

common =
  entry:
    app: PATHS.app
  output:
    path: PATHS.build
    filename: 'bundle.js'
  module:
    preLoaders: [
      {
        test: /\.coffee$/
        loader: 'coffeelint'
        include: PATHS.app
      }
      {
        test: /\.css$/
        loaders: ['postcss']
        include: PATHS.app
      }
    ]
    loaders: [
      {
        test: /\.coffee$/
        loader: 'coffee'
        include: PATHS.app
      }
      {
        test: /\.cjsx$/
        loaders: ['react-hot', 'coffee', 'cjsx']
        include: PATHS.app
      }
      {
        test: /\.css$/
        loaders: ['style', 'css']
        include: PATHS.app
      }
    ]
  resolve:
    extensions: ['', '.js', '.cjsx', '.coffee']
  postcss: ->
    [ stylelint(rules: 'color-hex-case': 'lower') ]

# Default configuration
if TARGET == 'start' or !TARGET
  module.exports = merge(common,
    devtool: 'eval-source-map'
    devServer:
      contentBase: PATHS.build
      historyApiFallback: true
      hot: true
      inline: true
      progress: true
      stats: 'errors-only'
      host: process.env.HOST
      port: process.env.PORT
    plugins: [
      new webpack.HotModuleReplacementPlugin()
      new NpmInstallPlugin({save: true})
    ]
  )

if TARGET == 'build'
  module.exports = merge(common, {})
