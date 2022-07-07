-- Feature view table
ALTER TABLE `hopsworks`.`training_dataset` DROP FOREIGN KEY `td_feature_view_fk`, DROP COLUMN `feature_view_id`;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `sample_ratio`;
ALTER TABLE `hopsworks`.`training_dataset_join` DROP FOREIGN KEY `tdj_feature_view_fk`, DROP COLUMN feature_view_id;
ALTER TABLE `hopsworks`.`training_dataset_filter` DROP FOREIGN KEY `tdfilter_feature_view_fk`, DROP COLUMN feature_view_id;
ALTER TABLE `hopsworks`.`training_dataset_feature` DROP FOREIGN KEY `tdf_feature_view_fk`, DROP COLUMN feature_view_id;
ALTER TABLE `hopsworks`.`feature_store_activity` DROP FOREIGN KEY `fsa_feature_view_fk`, DROP COLUMN feature_view_id;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `start_time`, DROP COLUMN `end_time`;
DROP TABLE IF EXISTS `hopsworks`.`feature_view`;

ALTER TABLE `hopsworks`.`training_dataset` DROP FOREIGN KEY `hopsfs_training_dataset_fk`;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `hopsfs_training_dataset_fk`
    FOREIGN KEY (`hopsfs_training_dataset_id`) REFERENCES `hopsfs_training_dataset` (`id`)
        ON DELETE CASCADE ON UPDATE NO ACTION;


ALTER TABLE `hopsworks`.`training_dataset` DROP FOREIGN KEY `FK_656_817`;
ALTER TABLE `hopsworks`.`training_dataset` DROP INDEX `name_version`;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `FK_656_817` FOREIGN KEY (`feature_store_id`) REFERENCES
    `feature_store` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `name_version` UNIQUE (`feature_store_id`, `name`, `version`);

ALTER TABLE `hopsworks`.`feature_store_connector` DROP FOREIGN KEY `fs_connector_kafka_fk`;
ALTER TABLE `hopsworks`.`feature_store_connector` DROP COLUMN `kafka_id`;

DROP TABLE IF EXISTS `hopsworks`.`feature_store_kafka_connector`;

ALTER TABLE `hopsworks`.`external_training_dataset`
    DROP FOREIGN KEY `ext_td_inode_fk`,
    DROP COLUMN `inode_pid`,
    DROP COLUMN `inode_name`,
    DROP COLUMN `partition_id`;

ALTER TABLE `hopsworks`.`serving` DROP COLUMN `description`;

-- StreamFeatureGroup
ALTER TABLE `hopsworks`.`cached_feature` DROP FOREIGN KEY `stream_feature_group_fk2`;
ALTER TABLE `hopsworks`.`cached_feature` DROP COLUMN `stream_feature_group_id`;
ALTER TABLE `hopsworks`.`feature_group` DROP FOREIGN KEY `stream_feature_group_fk`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `stream_feature_group_id`;
ALTER TABLE `hopsworks`.`cached_feature_extra_constraints` DROP COLUMN `stream_feature_group_id`;
DROP TABLE IF EXISTS `hopsworks`.`stream_feature_group`;
ALTER TABLE `hopsworks`.`feature_group_commit` MODIFY COLUMN `committed_on` TIMESTAMP NOT NULL;

ALTER TABLE `hopsworks`.`users` ADD COLUMN `orcid` varchar(20) COLLATE latin1_general_cs DEFAULT '-';

ALTER TABLE `hopsworks`.`users` MODIFY COLUMN `fname` varchar(30) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`users` MODIFY COLUMN `lname` varchar(30) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`feature_store_connector`
    DROP FOREIGN KEY `fs_connector_gcs_fk`,
    DROP COLUMN `gcs_id`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_gcs_connector`;

-- Unify serving resources config
SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`serving`
SET `predictor_resources` = JSON_EXTRACT(`predictor_resources`, "$.requests");
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`serving` DROP COLUMN `transformer_resources`;
ALTER TABLE `hopsworks`.`serving` RENAME COLUMN `predictor_resources` TO `docker_resource_config`;

ALTER TABLE `hopsworks`.`jupyter_settings` ADD COLUMN `git_config_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`jupyter_settings` ADD COLUMN `git_backend` TINYINT(1) DEFAULT 0;
CREATE TABLE IF NOT EXISTS `hopsworks`.`jupyter_git_config` (
                                                    `id` INT NOT NULL AUTO_INCREMENT,
                                                    `remote_git_url` VARCHAR(255) NOT NULL,
                                                    `api_key_name` VARCHAR(125) DEFAULT NULL,
                                                    `base_branch` VARCHAR(125),
                                                    `head_branch` VARCHAR(125),
                                                    `startup_auto_pull` TINYINT(1) DEFAULT 1,
                                                    `shutdown_auto_push` TINYINT(1) DEFAULT 1,
                                                    `git_backend` VARCHAR(45) DEFAULT 'GITHUB',
                                                    PRIMARY KEY (`id`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- bigquery connector
ALTER TABLE `hopsworks`.`feature_store_connector`
    DROP FOREIGN KEY `fs_connector_bigquery_fk`,
    DROP COLUMN `bigquery_id`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_bigquery_connector`;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`api_key_scope` SET `scope` = 'PYTHON' WHERE `scope` = 'PYTHON_LIBRARIES';
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`project_topics` DROP COLUMN `num_partitions`, DROP COLUMN `num_replicas`;

-- Data Validation
DROP TABLE IF EXISTS `hopsworks`.`validation_result`;
DROP TABLE IF EXISTS `hopsworks`.`validation_report`;
DROP TABLE IF EXISTS `hopsworks`.`great_expectation`;
DROP TABLE IF EXISTS `hopsworks`.`expectation`;
DROP TABLE IF EXISTS `hopsworks`.`expectation_suite`;

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `enable_batching` tinyint(1) DEFAULT '0';
SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`serving`
SET `enable_batching` =  (CASE WHEN `batching_configuration` = '{"batchingEnabled":false}'
    OR batching_configuration IS NULL
    then
    '0'
    else
    '1'
end);
SET SQL_SAFE_UPDATES = 1;
ALTER TABLE `hopsworks`.`serving` DROP COLUMN `batching_configuration`;

ALTER TABLE `hopsworks`.`api_key_scope` DROP FOREIGN KEY `fk_api_key_scope_1`;
ALTER TABLE `hopsworks`.`api_key_scope` ADD CONSTRAINT `fk_api_key_scope_1`
  FOREIGN KEY (`api_key`)
  REFERENCES `hopsworks`.`api_key` (`id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

CREATE TABLE  IF NOT EXISTS `feature_group_validation` (
                                                           `id` int(11) NOT NULL AUTO_INCREMENT,
                                                           `validation_time` TIMESTAMP(3),
                                                           `inode_pid` BIGINT(20) NOT NULL,
                                                           `inode_name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL,
                                                           `partition_id` BIGINT(20) NOT NULL,
                                                           `feature_group_id` INT(11),
                                                           `status` VARCHAR(20) COLLATE latin1_general_cs NOT NULL,
                                                           PRIMARY KEY (`id`),
                                                           KEY `feature_group_id` (`feature_group_id`),
                                                           CONSTRAINT `fg_fk_fgv` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
                                                           CONSTRAINT `featuregroupvalidation_inode_fk` FOREIGN KEY (`inode_pid`,`inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_group_commit` ADD COLUMN `validation_id` INT(11) NULL, ADD CONSTRAINT `fgc_fk_fgv` FOREIGN KEY (`validation_id`) REFERENCES `feature_group_validation` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION
ALTER TABLE `hopsworks`.`feature_group_commit` ADD COLUMN `validation_id` INT(11) NULL, ADD CONSTRAINT `fs_act_val_fk` FOREIGN KEY (`validation_id`) REFERENCES `feature_group_validation` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

CREATE TABLE IF NOT EXISTS `validation_rule` (
                                                 `id` int(11) NOT NULL AUTO_INCREMENT,
                                                 `name` varchar(45) COLLATE latin1_general_cs DEFAULT NULL,
                                                 `predicate` varchar(45) COLLATE latin1_general_cs DEFAULT NULL,
                                                 `accepted_type` varchar(45) COLLATE latin1_general_cs DEFAULT NULL,
                                                 `feature_type` varchar(45) COLLATE latin1_general_cs DEFAULT NULL,
                                                 `description` varchar(200) COLLATE latin1_general_cs DEFAULT NULL,
                                                 PRIMARY KEY (`id`),
                                                 UNIQUE KEY `unique_validation_rule` (`name`)
) ENGINE=ndbcluster AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_store_expectation` (
                                                           `id` int(11) NOT NULL AUTO_INCREMENT,
                                                           `name` varchar(100) COLLATE latin1_general_cs DEFAULT NULL,
                                                           `description` varchar(1000) COLLATE latin1_general_cs DEFAULT NULL,
                                                           `feature_store_id` int(11) NOT NULL,
                                                           `assertions` varchar(12000) COLLATE latin1_general_cs DEFAULT NULL,
                                                           PRIMARY KEY (`id`),
                                                           KEY `unique_fs_rules` (`feature_store_id`,`name`),
                                                           CONSTRAINT `fk_fs_expectation_to_fs` FOREIGN KEY (`feature_store_id`) REFERENCES `feature_store` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_group_expectation` (
                                                           `id` int(11) NOT NULL AUTO_INCREMENT,
                                                           `feature_group_id` int(11) NOT NULL,
                                                           `feature_store_expectation_id` int(11) NOT NULL,
                                                           `description` varchar(1000) COLLATE latin1_general_cs DEFAULT NULL,
                                                           PRIMARY KEY (`id`),
                                                           CONSTRAINT `fk_fg_expectation_to_fg` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
                                                           CONSTRAINT `fk_fg_expectation_to_fs_expectation` FOREIGN KEY (`feature_store_expectation_id`) REFERENCES `feature_store_expectation` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_store_expectation_rule` (
                                                                `feature_store_expectation_id` int(11) NOT NULL,
                                                                `validation_rule_id` int(11) NOT NULL,
                                                                PRIMARY KEY (`feature_store_expectation_id`, `validation_rule_id`),
                                                                CONSTRAINT `fk_fs_expectation_rule_id` FOREIGN KEY (`feature_store_expectation_id`) REFERENCES `feature_store_expectation` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
                                                                CONSTRAINT `fk_validation_rule_id` FOREIGN KEY (`validation_rule_id`) REFERENCES `validation_rule` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
