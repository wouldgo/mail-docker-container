/*global require,module*/
(function withNode() {
  'use strict';
  const hapi = require('hapi')
    //, model = require('./model')
    , server = new hapi.Server();

  //server.decorate('server', 'model', model);
  server.connection({
    'port': 3000
  });

  server.register([
    {
      'register': require('good'),
      'options': {
        'ops': {
          'interval': 480000
        },
        'reporters': {
          'console': [
            {
              'module': 'good-squeeze',
              'name': 'Squeeze',
              'args': [
                {
                  'log': '*',
                  'response': '*'
                }
              ]
            },
            {
              'module': 'good-console'
            },
            'stdout'
          ]
        }
      }
    }
  ], err => {

    if (err) {

      throw err;
    }
  });

  module.exports = server;
}());
