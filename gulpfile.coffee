gulp = require 'gulp'
path = require 'path'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
less = require 'gulp-less'
minifyCSS = require 'gulp-minify-css'
rename = require 'gulp-rename'
minifyHTML = require 'gulp-minify-html'
LessPluginAutoPrefix = require('less-plugin-autoprefix')

stylesSrc = './src/styles/app.less'

autoprefix = new LessPluginAutoPrefix
  browsers: [
    'last 3 Chrome versions'
    'last 3 Firefox versions'
  ]

gulp.task 'styles', ->

  gulp
    .src stylesSrc
    .pipe less({
      paths: [path.join(__dirname, 'src/styles')]
      plugins: [autoprefix]
    }).on 'error', (err) ->
      gutil.log(err)
      this.emit('end')
    .pipe gulp.dest('./public/css')
    .pipe minifyCSS()
    .pipe rename('app.min.css')
    .pipe gulp.dest('./public/css')


templatesSrc = './src/templates/*.html'

gulp.task 'templates', ->
  options = { empty: true }

  gulp
    .src templatesSrc
    .pipe minifyHTML(options)
    .pipe gulp.dest('./public')


gulp.task 'watch', ->
  gulp.watch './src/styles/*', ['styles']
  gulp.watch templatesSrc, ['templates']


gulp.task 'default', ['styles', 'templates', 'watch']
