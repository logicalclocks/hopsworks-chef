DROP TABLE IF EXISTS `hopsworks`.`featurestore_statistic`;

CREATE TABLE `feature_store_statistic` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `commit_time` VARCHAR(20) COLLATE latin1_general_cs NOT NULL,
  `inode_pid` BIGINT(20) NOT NULL,
  `inode_name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL,
  `partition_id` BIGINT(20) NOT NULL,
  `feature_group_id` INT(11),
  `training_dataset_id`INT(11),
  PRIMARY KEY (`id`),
  KEY `feature_group_id` (`feature_group_id`),
  KEY `training_dataset_id` (`training_dataset_id`),
  CONSTRAINT `fg_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `td_fk` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `inode_fk` FOREIGN KEY (`inode_pid`,`inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `cluster_analysis_enabled`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `num_clusters`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `num_bins`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `corr_method`;

ALTER TABLE `hopsworks`.`feature_store_s3_connector` DROP COLUMN `access_key`;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` DROP COLUMN `secret_key`;

ALTER TABLE `hopsworks`.`feature_store_s3_connector` MODIFY `name` VARCHAR(150) COLLATE latin1_general_cs  NOT NULL;

ALTER TABLE `hopsworks`.`secrets` MODIFY `secret_name` VARCHAR(200) COLLATE latin1_general_cs  NOT NULL;

CREATE TABLE `training_dataset_join` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `training_dataset` int(11) NULL,
  `feature_group` int(11) NULL,
  `type` tinyint(5) NOT NULL DEFAULT 0,
  `idx` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `fg_key` (`feature_group`),
  CONSTRAINT `td_fk` FOREIGN KEY (`training_dataset`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fg_left` FOREIGN KEY (`feature_group`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE `training_dataset_join_condition` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `td_join` int(11) NOT NULL,
  `left_feature` VARCHAR(1000) NOT NULL DEFAULT "",
  `right_feature` VARCHAR(1000) NOT NULL DEFAULT "",
  PRIMARY KEY (`id`),
  KEY `join_key` (`td_join`),
  CONSTRAINT `join_fk` FOREIGN KEY (`td_join`) REFERENCES `training_dataset_join` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

RENAME TABLE `hopsworks`.`feature_store_feature` TO `hopsworks`.`on_demand_feature`;

CREATE TABLE `training_dataset_feature` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `training_dataset` int(11) NULL,
  `feature_group` int(11) NULL,
  `name` varchar(1000) COLLATE latin1_general_cs NOT NULL,
  `type` varchar(1000) COLLATE latin1_general_cs,
  `td_join`int(11) NULL,
  `idx` int(11) NULL,
  PRIMARY KEY (`id`),
  KEY `td_key` (`training_dataset`),
  KEY `fg_key` (`feature_group`),
  CONSTRAINT `join_fk` FOREIGN KEY (`td_join`) REFERENCES `training_dataset_join` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION,
  CONSTRAINT `td_fk` FOREIGN KEY (`training_dataset`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fg_fk` FOREIGN KEY (`feature_group`) REFERENCES `feature_group` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

INSERT INTO `hopsworks`.`training_dataset_feature`(`training_dataset`, `name`, `type`) 
SELECT `training_dataset_id`, `name`, `type` FROM `hopsworks`.`on_demand_feature`
WHERE `training_dataset_id` IS NOT NULL; 

DELETE FROM `hopsworks`.`on_demand_feature` WHERE `training_dataset_id` IS NOT NULL;

SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "on_demand_feature" AND REFERENCED_TABLE_NAME="training_dataset");
SET @s := concat('ALTER TABLE hopsworks.on_demand_feature DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

ALTER TABLE `hopsworks`.`on_demand_feature` DROP KEY `training_dataset_id`;
ALTER TABLE `hopsworks`.`on_demand_feature` DROP COLUMN `training_dataset_id`;

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `query` TINYINT(1) NOT NULL DEFAULT '0';
