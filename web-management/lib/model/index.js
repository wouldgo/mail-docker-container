/*global require,module*/
(function withNode() {
  'use strict';

  const mysql = require('mysql')
    , poolOptions = require('./options/model.json')
    , pool = mysql.createPool(poolOptions);

  module.exports = {
    'domains': require('./domains')(pool),
    'users': require('./users')(pool),
    'aliases': require('./aliases')(pool)
  };
}());
