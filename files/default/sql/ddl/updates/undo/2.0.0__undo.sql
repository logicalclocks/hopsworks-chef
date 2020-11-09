DROP TABLE IF EXISTS `feature_store_statistic`;

CREATE TABLE `featurestore_statistic` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `feature_group_id` int(11) DEFAULT NULL,
  `training_dataset_id` int(11) DEFAULT NULL,
  `name` varchar(500) COLLATE latin1_general_cs DEFAULT NULL,
  `statistic_type` int(11) NOT NULL DEFAULT '0',
  `value` varchar(13300) COLLATE latin1_general_cs NOT NULL,
  PRIMARY KEY (`id`),
  KEY `feature_group_id` (`feature_group_id`),
  KEY `training_dataset_id` (`training_dataset_id`),
  CONSTRAINT `FK_693_956` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_812_957` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `cluster_analysis_enabled` TINYINT(1) NOT NULL DEFAULT '1';
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN`num_clusters` int(11) NOT NULL DEFAULT '5';
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `num_bins` INT(11) NOT NULL DEFAULT '20';
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `corr_method` VARCHAR(50) NOT NULL DEFAULT 'pearson';

ALTER TABLE `hopsworks`.`feature_store_s3_connector` ADD COLUMN `access_key` VARCHAR(1000) COLLATE latin1_general_cs
 DEFAULT NULL;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` ADD COLUMN `secret_key` VARCHAR(1000) COLLATE latin1_general_cs
 DEFAULT NULL;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` MODIFY `name` VARCHAR(1000) COLLATE latin1_general_cs  NOT NULL;

ALTER TABLE `hopsworks`.`secrets` MODIFY `secret_name` VARCHAR(125) COLLATE latin1_general_cs  NOT NULL;

DROP TABLE IF EXISTS `training_dataset_join`;
DROP TABLE IF EXISTS `training_dataset_join_condition`;
DROP TABLE IF EXISTS `training_dataset_feature`;

RENAME TABLE `hopsworks`.`on_demand_feature` TO `hopsworks`.`feature_store_feature`;

ALTER TABLE `hopsworks`.`feature_store_feature` ADD COLUMN `training_dataset_id` int(11) NULL;

ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `query`;

DROP TABLE IF EXISTS `hopsworks`.`feature_group_commit`;

ALTER TABLE `hopsworks`.`cached_feature_group` DROP COLUMN `timetravel_format`;

ALTER TABLE `hopsworks`.`training_dataset_join` DROP COLUMN `feature_group_commit_id`;

ALTER TABLE `hopsworks`.`cached_feature_group` ADD COLUMN `default_storage` TINYINT NULL;

ALTER TABLE `hopsworks`.`python_dep` ADD COLUMN `base_env` VARCHAR(45) COLLATE latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `hdfs_user_id` int(11) NOT NULL;

ALTER TABLE `hopsworks`.`on_demand_feature_group` 
    DROP FOREIGN KEY `on_demand_inode_fk`,
    DROP COLUMN `inode_pid`,
    DROP COLUMN `inode_name`,
    DROP COLUMN `partition_id`;

DROP TABLE IF EXISTS `hopsworks`.`cloud_role_mapping`;

DROP TABLE IF EXISTS `hopsworks`.`cloud_role_mapping_default`;

DROP TABLE IF EXISTS `databricks_instance`;

ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN `git_api_key_name`;

ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN `git_backend`;

ALTER TABLE `hopsworks`.`conda_commands` CHANGE `error_message` `error_message` VARCHAR(11000) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`training_dataset_feature` DROP COLUMN `label`;


