/*global module*/
(function withNode() {
  'use strict';

  module.exports = connection => ({
    'create': data => new Promise((resolve, reject) => {

      connection.query('INSERT INTO virtual_users (domain_id, password, email) VALUES (?, ?, ?)', [
        data.domainId,
        data.password,
        data.email
      ], err => {

        if (err) {

          return reject(err);
        }

        return resolve();
      });
    }),
    'oneById': id => new Promise((resolve, reject) => {

      connection.query('SELECT id, domain_id, password, email FROM virtual_users WHERE id = ?', id, (err, rows) => {

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
            'password': theUser.password,
            'email': theUser.email
          });
        }

        return reject();
      });
    }),
    'all': (limit = 200, offset = 0) => new Promise((resolve, reject) => {

      connection.query('SELECT COUNT(id) as \'users\' FROM virtual_users', (countErr, countRows) => {

        if (countErr) {

          return reject(countErr);
        } else if (countRows &&
          Array.isArray(countRows) &&
          countRows.length > 0) {
          const usersCount = countRows[0].users;

          return connection.query('SELECT id, domain_id, password, email FROM virtual_users LIMIT ? OFFSET ?', [
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
                'password': aRow.password,
                'email': aRow.email
              });
            }

            return resolve({
              'size': usersCount,
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

        return connection.query('UPDATE virtual_users SET domain_id = ?, password = ?, email = ? WHERE id = ?', [
          data.name,
          data.domainId,
          data.password,
          data.email,
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

      return connection.query('DELETE FROM virtual_users WHERE id = ?', id, err => {

        if (err) {

          return reject(err);
        }

        return resolve();
      });
    })
  });
}());
