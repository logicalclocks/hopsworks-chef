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
