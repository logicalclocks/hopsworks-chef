ALTER TABLE `hopsworks`.`python_dep` ADD COLUMN `base_env` VARCHAR(45) COLLATE latin1_general_cs;

TRUNCATE TABLE `hopsworks`.`conda_commands`;
-- drop foreign key to project it is not always pointing to a project now.
SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "conda_commands" AND REFERENCED_TABLE_NAME="projects");
SET @s := concat('ALTER TABLE hopsworks.conda_commands DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;
ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN `host_id`, DROP INDEX `host_id` ;
ALTER TABLE `hopsworks`.`conda_commands` CHANGE `proj` `docker_image` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`jupyter_project` CHANGE `pid` `cid` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`tensorboard` CHANGE `pid` `cid` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`serving` CHANGE `local_pid` `cid` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`conda_commands` ADD COLUMN `error_message` VARCHAR(6000) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`conda_commands` CHANGE `environment_yml` `environment_yml` VARCHAR(6000) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`jupyter_settings` CHANGE COLUMN `base_dir` `base_dir` varchar(255) COLLATE latin1_general_cs DEFAULT NULL;

UPDATE `hopsworks`.`jupyter_settings` `j`
JOIN `hopsworks`.`project` `p`
ON `j`.`project_id` = `p`.`id`
SET `j`.`base_dir` = CONCAT('/Projects/',`p`.`projectname`,'/Jupyter');

ALTER TABLE `hopsworks`.`jupyter_git_config` ADD COLUMN `git_backend` VARCHAR(45) COLLATE latin1_general_cs DEFAULT 'GITHUB';

ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN machine_type;
ALTER TABLE `hopsworks`.`python_dep` DROP COLUMN machine_type;
ALTER TABLE `hopsworks`.`hosts` DROP COLUMN conda_enabled;

ALTER TABLE `hopsworks`.`cached_feature_group` ADD COLUMN `online_enabled` TINYINT DEFAULT 0; 

-- Migrate the flag from the previous version to the new version
UPDATE `hopsworks`.`cached_feature_group` SET online_enabled=1 WHERE `online_feature_group` IS NOT NULL;

ALTER TABLE `hopsworks`.`cached_feature_group` DROP FOREIGN KEY `online_fg_fk`; 
ALTER TABLE `hopsworks`.`cached_feature_group` DROP COLUMN `online_feature_group`; 
DROP TABLE `hopsworks`.`online_feature_group`;

ALTER TABLE `hopsworks`.`cached_feature_group` ADD COLUMN `default_storage` TINYINT DEFAULT 0;

DROP TABLE IF EXISTS `hopsworks`.`tf_lib_mapping`;

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
