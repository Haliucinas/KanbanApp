path = require 'path'
merge = require 'webpack-merge'
webpack = require 'webpack'
NpmInstallPlugin = require 'npm-install-webpack-plugin'
stylelint = require 'stylelint'
pkg = require './package.json'
HtmlWebpackPlugin = require 'html-webpack-plugin'
CleanPlugin = require 'clean-webpack-plugin'
ExtractTextPlugin = require 'extract-text-webpack-plugin'

TARGET = process.env.npm_lifecycle_event
PATHS =
  app: path.join(__dirname, 'app')
  build: path.join(__dirname, 'build')
  style: path.join(__dirname, 'app/main.css')

common =
  entry:
    app: PATHS.app
    style: PATHS.style
  output:
    path: PATHS.build
    filename: '[name].js'
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
    ]
  plugins: [
    new HtmlWebpackPlugin(
      template: 'node_modules/html-webpack-template/index.ejs'
      title: 'Kanban app'
      appMountId: 'app'
      inject: false
    )
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
      historyApiFallback: true
      hot: true
      inline: true
      progress: true
      stats: 'errors-only'
      host: process.env.HOST
      port: process.env.PORT
    module:
      loaders: [
        {
          test: /\.css$/
          loaders: ['style', 'css']
          include: PATHS.app
        }
      ]
    plugins: [
      new webpack.HotModuleReplacementPlugin()
      new NpmInstallPlugin({save: true})
    ]
  )

if TARGET == 'build' or TARGET == 'stats'
  module.exports = merge(common,
    entry:
      vendor: Object.keys(pkg.dependencies).filter((v) ->
        v != 'alt-utils'
      )
    output:
      path: PATHS.build
      filename: 'assets/js/[name].[chunkhash].js'
      chunkFilename: 'assets/js/[chunkhash].js'
    module:
      loaders: [
        {
          test: /\.css$/
          loader: ExtractTextPlugin.extract('style', 'css')
          include: PATHS.app
        }
      ]
    plugins: [
      new CleanPlugin([PATHS.build])
      new ExtractTextPlugin('assets/style/[name].[chunkhash].css', { allChunks: true })
      new webpack.optimize.CommonsChunkPlugin({names: ['vendor', 'manifest']})
      new webpack.DefinePlugin({'process.env.NODE_ENV': '"production"'})
      new webpack.optimize.UglifyJsPlugin(compress: warnings: false)
    ]
  )
