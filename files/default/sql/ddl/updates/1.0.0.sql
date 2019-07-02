CREATE TABLE IF NOT EXISTS `users_third_party_api_keys` (
       `uid` INT NOT NULL,
       `key_name` VARCHAR(125) NOT NULL,
       `key` VARBINARY(5000) NOT NULL,
       `added_on` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
       PRIMARY KEY (`uid`, `key_name`),
       FOREIGN KEY `3rdparty_key_uid` (`uid`) REFERENCES `users` (`uid`)
          ON DELETE CASCADE
          ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
