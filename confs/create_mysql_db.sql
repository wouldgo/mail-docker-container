DROP SCHEMA IF EXISTS `servermail`;
CREATE SCHEMA `servermail`;
GRANT USAGE ON *.* TO 'usermail'@'%';
DROP USER 'usermail'@'%';
CREATE USER 'usermail'@'%';
SET PASSWORD FOR 'usermail'@'%' = PASSWORD('%MAILUSER_PSW%');
GRANT SELECT ON `servermail`.* TO 'usermail'@'%';
FLUSH PRIVILEGES;
USE 'servermail';
CREATE TABLE `virtual_domains` (
	`id` int(11) NOT NULL auto_increment,
	`name` varchar(50) NOT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `virtual_users` (
	`id` int(11) NOT NULL auto_increment,
	`domain_id` int(11) NOT NULL,
	`password` varchar(106) NOT NULL,
	`email` varchar(100) NOT NULL, PRIMARY KEY (`id`), UNIQUE KEY `email` (`email`), FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `virtual_aliases` (
	`id` int(11) NOT NULL auto_increment,
	`domain_id` int(11) NOT NULL,
	`source` varchar(100) NOT NULL,
	`destination` varchar(100) NOT NULL, PRIMARY KEY (`id`), FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8;
