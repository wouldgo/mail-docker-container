/*global require,__dirname,module*/
(function withNode() {
  'use strict';

  module.exports = server => {
    const fs = require('fs')
      , path = require('path')
      , boom = require('boom');

    fs.readdir(path.resolve(__dirname), (err, files) => {

      if (err) {

        throw err;
      }

      files.filter(element => element.endsWith('.js') && element !== 'index.js')
        .forEach(element => {

          server.log('info', `Going to load ${element} as route...`);
          server.route(require(`${__dirname}/${element}`)(boom));
          server.log('info', `${element} loaded as route.`);
        });
    });
  };
}());
