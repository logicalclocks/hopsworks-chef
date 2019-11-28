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
DROP TABLE IF EXISTS `hopsworks`.`subjects_compatibility`;

RENAME TABLE `hopsworks`.`subjects` TO `hopsworks`.`schema_topics`;
ALTER TABLE `hopsworks`.`schema_topics` DROP CONSTRAINT `Subject_Constraint`;
ALTER TABLE `hopsworks`.`schema_topics` DROP CONSTRAINT `project_idx`;
ALTER TABLE `hopsworks`.`schema_topics` DROP COLUMN `id`;
ALTER TABLE `hopsworks`.`schema_topics` DROP COLUMN `project_id`;
ALTER TABLE `hopsworks`.`schema_topics` CHANGE COLUMN `subject` `name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`schema_topics` CHANGE COLUMN `schema` `contents` VARCHAR(10000) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`schema_topics` ADD PRIMARY KEY (`name`, `version`);

ALTER TABLE `hopsworks`.`project_topics` DROP KEY `subject_name_idx`;
ALTER TABLE `hopsworks`.`project_topics` DROP KEY `subject_idx`;
ALTER TABLE `hopsworks`.`project_topics` DROP CONSTRAINT `subject_idx`;
ALTER TABLE `hopsworks`.`project_topics` CHANGE COLUMN `subject` `schema_name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`project_topics` CHANGE COLUMN `subject_version` `schema_version` INT(11) NOT NULL;
ALTER TABLE `hopsworks`.`project_topics` ADD KEY `schema_name_idx` (`schema_name`);
ALTER TABLE `hopsworks`.`project_topics` ADD KEY `schema_idx` (`schema_name`,`schema_version`);
ALTER TABLE `hopsworks`.`project_topics` ADD CONSTRAINT `schema_idx` FOREIGN KEY (`schema_name`,`schema_version`) REFERENCES `schema_topics` (`name`,`version`) ON DELETE NO ACTION ON UPDATE NO ACTION;


