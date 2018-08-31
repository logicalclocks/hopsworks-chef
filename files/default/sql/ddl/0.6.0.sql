--
--  TensorBoard visualization for experiments service
--
CREATE TABLE IF NOT EXISTS `tensorboard` (
  `project_id` INT(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `hdfs_user_id` int(11) NOT NULL,
  `endpoint` VARCHAR(100) NOT NULL,
  `elastic_id` VARCHAR(100) NOT NULL,
  `pid` BIGINT NOT NULL,
  `last_accessed` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hdfs_logdir` VARCHAR(10000) NOT NULL,
  PRIMARY KEY (`project_id`,`user_id`),
  FOREIGN KEY `project_id_fk` (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY `user_id_fk` (`user_id`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY `hdfs_user_id_fk` (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hosts` DROP KEY `hostname`;
ALTER TABLE `hosts` ADD UNIQUE KEY `hostname`(`hostname`);
ALTER TABLE `hosts` DROP KEY `host_ip`;
ALTER TABLE `hosts` ADD UNIQUE KEY `host_ip`(`host_ip`);
