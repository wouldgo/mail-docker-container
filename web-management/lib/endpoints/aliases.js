/*global module*/
(function withNode() {
  'use strict';

  module.exports = boom => [
    {
      'method': 'GET',
      'path': '/aliases/all',
      'handler': (request, reply) => {

        request.server.model.aliases.all(request.query.limit, request.query.offset)
          .then(element => reply(element))
          .catch(err => reply(boom.badGateway(err)));
      }
    },
    {
      'method': 'GET',
      'path': '/aliases/{id}',
      'handler': (request, reply) => {

        request.server.model.aliases.oneById(request.params.id)
          .then(element => reply(element))
          .catch(err => reply(boom.badGateway(err)));
      }
    },
    {
      'method': 'DELETE',
      'path': '/aliases/{id}',
      'handler': (request, reply) => {

        request.server.model.aliases.delete(request.params.id)
          .then(() => reply())
          .catch(err => reply(boom.badGateway(err)));
      }
    }
  ];
}());
