ALTER TABLE `hopsworks`.`jobs` CHANGE COLUMN `json_config` `json_config` TEXT COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`jupyter_settings` CHANGE COLUMN `job_config` `json_config` TEXT COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`message` CHANGE COLUMN `content` `content` TEXT COLLATE latin1_general_cs NOT NULL;

DROP TABLE IF EXISTS `hopsworks`.`dataset_shared_with`;

ALTER TABLE `hopsworks`.`dataset`
ADD `shared` tinyint(1) NOT NULL DEFAULT '0',
ADD `status` tinyint(1) NOT NULL DEFAULT '1',
ADD `editable` tinyint(1) NOT NULL DEFAULT '1',
DROP INDEX `uq_dataset` ,
ADD UNIQUE INDEX `uq_dataset` (`inode_pid`,`projectId`,`inode_name`);

ALTER TABLE hopsworks.`jupyter_settings` DROP COLUMN `python_kernel`;
ALTER TABLE hopsworks.`jupyter_settings` DROP COLUMN `docker_config`;

ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `desc_stats_enabled`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `feat_corr_enabled`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `feat_hist_enabled`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `cluster_analysis_enabled`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `num_clusters`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `num_bins`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `corr_method`;

DROP TABLE IF EXISTS `hopsworks`.`statistic_columns`;
