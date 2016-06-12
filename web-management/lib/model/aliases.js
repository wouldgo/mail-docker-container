/*global module*/
(function withNode() {
  'use strict';

  module.exports = connection => ({
    'create': data => new Promise((resolve, reject) => {

      connection.query('INSERT INTO virtual_aliases (domain_id, source, destination) VALUES (?, ?, ?)', [
        data.domainId,
        data.source,
        data.destination
      ], err => {

        if (err) {

          return reject(err);
        }

        return resolve();
      });
    }),
    'oneById': id => new Promise((resolve, reject) => {

      connection.query('SELECT id, domain_id, source, destination FROM virtual_aliases WHERE id = ?', id, (err, rows) => {

        if (err) {

          return reject(err);
        }

        if (rows &&
          Array.isArray(rows) &&
          rows.length > 0) {
          const theUser = rows[0];

          return resolve({
            'id': theUser.id,
            'domainId': theUser.domain_id,
            'source': theUser.source,
            'destination': theUser.destination
          });
        }

        return reject();
      });
    }),
    'all': (limit, offset) => new Promise((resolve, reject) => {

      connection.query('SELECT COUNT(id) as \'aliases\' FROM virtual_aliases', (countErr, countRows) => {

        if (countErr) {

          return reject(countErr);
        } else if (countRows &&
          Array.isArray(countRows) &&
          countRows.length > 0) {
          const aliasesCount = countRows[0].aliases;

          return connection.query('SELECT id, domain_id, source, destination FROM virtual_aliases LIMIT ? OFFSET ?', [
            limit,
            offset
          ], (err, rows) => {

            if (err) {

              return reject(err);
            }
            const listToReturn = [];

            for (const aRow of rows) {

              listToReturn.push({
                'id': aRow.id,
                'domainId': aRow.domain_id,
                'source': aRow.source,
                'destination': aRow.destination
              });
            }

            return resolve({
              'size': aliasesCount,
              'page': offset,
              'elementInPage': limit,
              'content': listToReturn
            });
          });
        }

        return reject();
      });
    }),
    'update': (id, data) => new Promise((resolve, reject) => {

      if (data &&
        data.name) {

        return connection.query('UPDATE virtual_aliases SET domain_id = ?, source = ?, destination = ? WHERE id = ?', [
          data.domainId,
          data.source,
          data.destination,
          id
        ], err => {

          if (err) {

            return reject(err);
          }

          return resolve();
        });
      }

      return reject();
    }),
    'delete': id => new Promise((resolve, reject) => {

      return connection.query('DELETE FROM virtual_aliases WHERE id = ?', id, err => {

        if (err) {

          return reject(err);
        }

        return resolve();
      });
    })
  });
}());
