DROP SCHEMA IF EXISTS `mailserver`;
CREATE SCHEMA `mailserver`;
GRANT SELECT ON `mailserver`.* TO `mailuser`@`0.0.0.0` IDENTIFIED BY '%MAILUSER_PSW%';
USE `mailserver`;
CREATE TABLE `virtual_domains` ( `id` int(11) NOT NULL auto_increment, `name` varchar(50) NOT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `virtual_users` ( `id` int(11) NOT NULL auto_increment, `domain_id` int(11) NOT NULL, `password` varchar(106) NOT NULL, `email` varchar(100) NOT NULL, PRIMARY KEY (`id`), UNIQUE KEY `email` (`email`), FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `virtual_aliases` ( `id` int(11) NOT NULL auto_increment, `domain_id` int(11) NOT NULL, `source` varchar(100) NOT NULL, `destination` varchar(100) NOT NULL, PRIMARY KEY (`id`), FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8;
