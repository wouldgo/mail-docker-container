/* global require,__dirname*/
(function withNode() {
  'use strict';

  const path = require('path')
    , gulp = require('gulp')
    , nodemon = require('gulp-nodemon')
    , eslint = require('gulp-eslint')
    , executableFile = path.resolve(__dirname, 'index.js')
    , libFolder = path.resolve(__dirname, 'lib/**/*.js')
    , jsFiles = [
      executableFile,
      libFolder
    ]
    , nodeMonOpts = {
      'script': executableFile,
      'watch': jsFiles
    };

  gulp.task('lint', () => {

    return gulp.src(jsFiles)
      .pipe(eslint())
      .pipe(eslint.format())
      .pipe(eslint.failOnError());
  });

  gulp.task('default', ['lint'], () => {
    const stream = nodemon(nodeMonOpts);

    stream.on('crash', function OnNodeCrash() {

      this.emit('restart');
    });

    return stream;
  });
}());
