/*global module*/
(function withNode() {
  'use strict';

  module.exports = connection => ({
    'create': data => new Promise((resolve, reject) => {

      connection.query('INSERT INTO virtual_domains (name) VALUES (?)', data.name, err => {

        if (err) {

          return reject(err);
        }

        return resolve();
      });
    }),
    'oneByName': name => new Promise((resolve, reject) => {

      connection.query('SELECT id, name FROM virtual_domains WHERE name = ?', name, (err, rows) => {

        if (err) {

          return reject(err);
        }

        if (rows &&
          Array.isArray(rows) &&
          rows.length > 0) {
          const theDomain = rows[0];

          return resolve({
            'id': theDomain.id,
            'name': theDomain.name
          });
        }

        return reject();
      });
    }),
    'oneById': id => new Promise((resolve, reject) => {

      connection.query('SELECT id, name FROM virtual_domains WHERE id = ?', id, (err, rows) => {

        if (err) {

          return reject(err);
        }

        if (rows &&
          Array.isArray(rows) &&
          rows.length > 0) {
          const theDomain = rows[0];

          return resolve({
            'id': theDomain.id,
            'name': theDomain.name
          });
        }

        return reject();
      });
    }),
    'all': (limit = 100, offset = 0) => new Promise((resolve, reject) => {

      connection.query('SELECT COUNT(id) as \'domains\' FROM virtual_domains', (countErr, countRows) => {

        if (countErr) {

          return reject(countErr);
        } else if (countRows &&
          Array.isArray(countRows) &&
          countRows.length > 0) {
          const domainsCount = countRows[0].domains;

          return connection.query('SELECT id, name FROM virtual_domains LIMIT ? OFFSET ?', [limit, offset], (err, rows) => {

            if (err) {

              return reject(err);
            }
            const listToReturn = [];

            for (const aRow of rows) {

              listToReturn.push({
                'id': aRow.id,
                'name': aRow.name
              });
            }

            return resolve({
              'size': domainsCount,
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

        return connection.query('UPDATE virtual_domains SET name = ? WHERE id = ?', [data.name, id], err => {

          if (err) {

            return reject(err);
          }

          return resolve();
        });
      }

      return reject();
    }),
    'delete': id => new Promise((resolve, reject) => {

      return connection.query('DELETE FROM virtual_domains WHERE id = ?', id, err => {

        if (err) {

          return reject(err);
        }

        return resolve();
      });
    })
  });
}());
