--
--  TensorBoard visualization for experiments service
--
CREATE TABLE IF NOT EXISTS `tensorboard` (
  `project_id` INT(11) NOT NULL,
  `team_member` VARCHAR(150) NOT NULL,
  `hdfs_user_id` int(11) NOT NULL,
  `endpoint` VARCHAR(100) NOT NULL,
  `elastic_id` VARCHAR(100) NOT NULL,
  `pid` BIGINT NOT NULL,
  `last_accessed` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `hdfs_logdir` VARCHAR(10000) NOT NULL,
  PRIMARY KEY (`project_id`,`team_member`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`team_member`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
