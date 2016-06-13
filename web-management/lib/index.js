/*global __dirname,require,module*/
(function withNode() {
  'use strict';
  const hapi = require('hapi')
    , path = require('path')
    //, model = require('./model')
    , server = new hapi.Server();

  //server.decorate('server', 'model', model);
  server.connection({
    'port': 3000
  });

  server.register([
    require('inert'),
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

  server.route({
    'method': 'GET',
    'path': '/management/{param*}',
    'handler': {
      'directory': {
        'path': path.resolve(__dirname, 'views')
      }
    }
  });

  require('./endpoints')(server);

  module.exports = server;
}());
