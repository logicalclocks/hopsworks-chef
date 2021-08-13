CREATE TABLE IF NOT EXISTS `feature_store_code` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `commit_time` DATETIME(3) NOT NULL,
  `inode_pid` BIGINT(20) NOT NULL,
  `inode_name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL,
  `partition_id` BIGINT(20) NOT NULL,
  `feature_group_id` INT(11),
  `feature_group_commit_id` BIGINT(20),
  `training_dataset_id`INT(11),
  `application_id`VARCHAR(50),
  PRIMARY KEY (`id`),
  KEY `feature_group_id` (`feature_group_id`),
  KEY `training_dataset_id` (`training_dataset_id`),
  KEY `feature_group_commit_id_fk` (`feature_group_id`, `feature_group_commit_id`),
  CONSTRAINT `fg_fk_fsc` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fg_ci_fk_fsc` FOREIGN KEY (`feature_group_id`, `feature_group_commit_id`) REFERENCES `feature_group_commit` (`feature_group_id`, `commit_id`) ON DELETE SET NULL ON UPDATE NO ACTION,
  CONSTRAINT `td_fk_fsc` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `inode_fk_fsc` FOREIGN KEY (`inode_pid`,`inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`on_demand_feature` ADD COLUMN `idx` int(11) NOT NULL DEFAULT 0;

DROP TABLE `hopsworks`.`ndb_backup`;

DROP TABLE `project_devices`;
DROP TABLE `project_devices_settings`;

ALTER TABLE `hopsworks`.`dataset_shared_with` ADD COLUMN `shared_by` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`dataset_shared_with` ADD COLUMN `accepted_by` INT(11) DEFAULT NULL;

ALTER TABLE `hopsworks`.`dataset_shared_with` ADD CONSTRAINT `fk_shared_by` FOREIGN KEY (`shared_by`) REFERENCES `users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`dataset_shared_with` ADD CONSTRAINT `fk_accepted_by` FOREIGN KEY (`accepted_by`) REFERENCES `users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `event_time` VARCHAR(63) DEFAULT NULL;
