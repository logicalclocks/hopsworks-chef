CREATE TABLE IF NOT EXISTS `secrets` (
       `uid` INT NOT NULL,
       `secret_name` VARCHAR(125) NOT NULL,
       `secret` VARBINARY(10000) NOT NULL,
       `added_on` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
       `visibility` TINYINT NOT NULL,
       `pid_scope` INT DEFAULT NULL,
       PRIMARY KEY (`uid`, `secret_name`),
       FOREIGN KEY `secret_uid` (`uid`) REFERENCES `users` (`uid`)
          ON DELETE CASCADE
          ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`users` ADD COLUMN `validation_key_updated` timestamp DEFAULT NULL;
ALTER TABLE `hopsworks`.`users` ADD COLUMN `validation_key_type` VARCHAR(20) DEFAULT NULL;
ALTER TABLE `hopsworks`.`users` CHANGE COLUMN `activated` `activated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

CREATE TABLE IF NOT EXISTS `api_key` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prefix` varchar(45) NOT NULL,
  `secret` varchar(512) NOT NULL,
  `salt` varchar(256) NOT NULL,
  `created` timestamp NOT NULL,
  `modified` timestamp NOT NULL,
  `name` varchar(45) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `prefix_UNIQUE` (`prefix`),
  UNIQUE KEY `index4` (`user_id`,`name`),
  KEY `fk_api_key_1_idx` (`user_id`),
  CONSTRAINT `fk_api_key_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION) 
  ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `api_key_scope` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `api_key` int(11) NOT NULL,
  `scope` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index2` (`api_key`,`scope`),
  CONSTRAINT `fk_api_key_scope_1` FOREIGN KEY (`api_key`) REFERENCES `api_key` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION) 
  ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
