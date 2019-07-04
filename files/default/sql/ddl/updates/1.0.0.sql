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
  `id` INT(11) NOT NULL,
  `key` VARCHAR(512) NOT NULL,
  `salt` VARCHAR(256) NOT NULL,
  `created` TIMESTAMP NOT NULL,
  `modified` TIMESTAMP NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `user` INT(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `key_UNIQUE` (`key` ASC),
  UNIQUE INDEX `salt_UNIQUE` (`salt` ASC),
  INDEX `fk_api_key_1_idx` (`user` ASC),
  CONSTRAINT `fk_api_key_1`
    FOREIGN KEY (`user`)
    REFERENCES `users` (`uid`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `api_key_scope` (
  `id` INT(11) NOT NULL,
  `api_key` INT(11) NOT NULL,
  `scope` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `index2` (`api_key` ASC, `scope` ASC),
  CONSTRAINT `fk_api_key_scope_1`
    FOREIGN KEY (`api_key`)
    REFERENCES `api_key` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
