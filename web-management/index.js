/*global require*/
(function withNode() {
  'use strict';
  const webManagement = require('./lib');

  webManagement.start(err => {

    if (err) {

      throw err;
    }

    webManagement.log('info', `Server running at: ${webManagement.info.uri} ...`);
  });
}());
