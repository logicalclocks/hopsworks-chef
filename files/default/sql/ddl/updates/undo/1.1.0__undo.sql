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

CREATE TABLE `schema_topics` (
  `name` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `version` int(11) NOT NULL,
  `contents` varchar(10000) COLLATE latin1_general_cs NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`name`,`version`),
  KEY `created_on_idx` (`created_on`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

REPLACE INTO `hopsworks`.`schema_topics`(`name`, `version`, `contents`) VALUES ('inferenceschema', 1, '{"fields": [{"name": "modelId", "type": "int"}, { "name": "modelName", "type": "string" }, {  "name": "modelVersion",  "type": "int" }, {  "name": "requestTimestamp",  "type": "long" }, {  "name": "responseHttpCode",  "type": "int" }, {  "name": "inferenceRequest",  "type": "string" }, {  "name": "inferenceResponse",  "type": "string" }  ],  "name": "inferencelog",  "type": "record" }');

REPLACE INTO `hopsworks`.`schema_topics`(`name`, `version`, `contents`) VALUES ('inferenceschema', 2, '{"fields": [{"name": "modelId", "type": "int"}, { "name": "modelName", "type": "string" }, {  "name": "modelVersion",  "type": "int" }, {  "name": "requestTimestamp",  "type": "long" }, {  "name": "responseHttpCode",  "type": "int" }, {  "name": "inferenceRequest",  "type": "string" }, {  "name": "inferenceResponse",  "type": "string" }, { "name": "servingType", "type": "string" } ],  "name": "inferencelog",  "type": "record" }');

REPLACE INTO `schema_topics` (`name`, `version`, `contents`, `created_on`)
	SELECT 
		A.`subject` AS `name`,
		A.`version` AS `version`,
		B.`schema` AS `contents`,
		A.`created_on` AS `created_on`
	FROM
		`subjects` A
			JOIN
		`schemas` B ON A.schema_id = B.id
			AND A.project_id = B.project_id
	GROUP BY `name` , `version` , `contents` , `created_on`;

ALTER TABLE `hopsworks`.`project_topics` ADD COLUMN `schema_name` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`project_topics` ADD COLUMN `schema_version` int(11) NOT NULL;
ALTER TABLE `hopsworks`.`project_topics` DROP FOREIGN KEY `subject_idx`;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`project_topics` pt
  JOIN 
    `hopsworks`.`subjects` s ON pt.`subject_id` = s.`id`
SET 
  pt.`schema_name` = s.`subject`,
  pt.`schema_version` = s.`version`;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`project_topics` DROP COLUMN `subject_id`;
ALTER TABLE `hopsworks`.`project_topics` ADD KEY `schema_name_idx` (`schema_name`);
ALTER TABLE `hopsworks`.`project_topics` ADD KEY `schema_idx` (`schema_name`,`schema_version`);
ALTER TABLE `hopsworks`.`project_topics` ADD CONSTRAINT `schema_idx` FOREIGN KEY (`schema_name`,`schema_version`) REFERENCES `schema_topics` (`name`,`version`) ON DELETE NO ACTION ON UPDATE NO ACTION;
  

DROP TABLE IF EXISTS `subjects`;

DROP TABLE IF EXISTS `schemas`;

ALTER TABLE `hopsworks`.`executions` DROP COLUMN `args`;

ALTER TABLE `hopsworks`.`tensorboard` CHANGE `ml_id` `elastic_id` varchar(100) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`conda_commands` DROP FOREIGN KEY `user_fk`;
ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN `user_id`;