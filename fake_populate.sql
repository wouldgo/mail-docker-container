INSERT INTO `mailserver`.`virtual_domains` (
  `id`,
  `name`
)
VALUES (
  '1', 'domainA.com'),
( '4', 'domainD.com'),
( '5', 'domainE.com');

INSERT INTO `mailserver`.`virtual_users` (
  `domain_id`,
  `password`,
  `email`
  )
VALUES(
  '1', ENCRYPT('longpw', CONCAT('$6$', SUBSTRING(SHA(RAND()), -16))), 'user1@domainA.com'),
( '1', ENCRYPT('longpw', CONCAT('$6$', SUBSTRING(SHA(RAND()), -16))), 'user2@domainA.com'),
( '5', ENCRYPT('longpw', CONCAT('$6$', SUBSTRING(SHA(RAND()), -16))), 'user3@domainE.com'),
( '4', ENCRYPT('longpw', CONCAT('$6$', SUBSTRING(SHA(RAND()), -16))), 'user4@domainD.com'),
( '4', ENCRYPT('longpw', CONCAT('$6$', SUBSTRING(SHA(RAND()), -16))), 'user5@domainD.com');

INSERT INTO `mailserver`.`virtual_aliases` (
  `id`,
  `domain_id`,
  `source`,
  `destination`
)
VALUES (
  '1', '1', 'antani@domainA.com', 'user1@domainA.com'
);
