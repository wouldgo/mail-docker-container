/*global module*/
(function withNode() {
  'use strict';

  module.exports = boom => [
    {
      'method': 'GET',
      'path': '/users/all',
      'handler': (request, reply) => {

        request.server.model.users.all(request.query.limit, request.query.offset)
          .then(element => reply(element))
          .catch(err => reply(boom.badGateway(err)));
      }
    },
    {
      'method': 'GET',
      'path': '/users/{id}',
      'handler': (request, reply) => {

        request.server.model.users.oneById(request.params.id)
          .then(element => reply(element))
          .catch(err => reply(boom.badGateway(err)));
      }
    },
    {
      'method': 'DELETE',
      'path': '/users/{id}',
      'handler': (request, reply) => {

        request.server.model.users.delete(request.params.id)
          .then(() => reply())
          .catch(err => reply(boom.badGateway(err)));
      }
    }
  ];
}());
