/*global module*/
(function withNode() {
  'use strict';

  module.exports = boom => [
    {
      'method': 'GET',
      'path': '/domains/all',
      'handler': (request, reply) => {

        request.server.model.domains.all(request.query.limit, request.query.offset)
          .then(element => reply(element))
          .catch(err => reply(boom.badGateway(err)));
      }
    },
    {
      'method': 'GET',
      'path': '/domains/{id}',
      'handler': (request, reply) => {

        request.server.model.domains.oneById(request.params.id)
          .then(element => reply(element))
          .catch(err => reply(boom.badGateway(err)));
      }
    },
    {
      'method': 'DELETE',
      'path': '/domains/{id}',
      'handler': (request, reply) => {

        request.server.model.domains.delete(request.params.id)
          .then(() => reply())
          .catch(err => reply(boom.badGateway(err)));
      }
    }
  ];
}());
