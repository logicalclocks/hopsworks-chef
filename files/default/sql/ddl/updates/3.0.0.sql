-- Add ModelFeature entity
CREATE TABLE `feature_view` (
                                 `id` int(11) NOT NULL AUTO_INCREMENT,
                                 `name` varchar(63) NOT NULL,
                                 `feature_store_id` int(11) NOT NULL,
                                 `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                                 `creator` int(11) NOT NULL,
                                 `version` int(11) NOT NULL,
                                 `description` varchar(10000) COLLATE latin1_general_cs DEFAULT NULL,
                                 `inode_pid` BIGINT(20) NOT NULL,
                                 `inode_name` VARCHAR(255) NOT NULL,
                                 `partition_id` BIGINT(20) NOT NULL,
                                 PRIMARY KEY (`id`),
                                 UNIQUE KEY `name_version` (`feature_store_id`, `name`, `version`),
                                 KEY `feature_store_id` (`feature_store_id`),
                                 KEY `creator` (`creator`),
                                 CONSTRAINT `fv_creator_fk` FOREIGN KEY (`creator`) REFERENCES `users` (`uid`) ON
                                     DELETE NO ACTION ON UPDATE NO ACTION,
                                 CONSTRAINT `fv_feature_store_id_fk` FOREIGN KEY (`feature_store_id`) REFERENCES
                                     `feature_store` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
                                 CONSTRAINT `fv_inode_fk` FOREIGN KEY (`inode_pid`, `inode_name`, `partition_id`) REFERENCES
                                     `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `feature_view_id` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `sample_ratio` FLOAT DEFAULT NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `td_feature_view_fk` FOREIGN KEY
    (`feature_view_id`) REFERENCES `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`training_dataset_join` ADD COLUMN `feature_view_id` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`training_dataset_join` ADD CONSTRAINT `tdj_feature_view_fk` FOREIGN KEY (`feature_view_id`) REFERENCES
    `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`training_dataset_filter` ADD COLUMN `feature_view_id` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`training_dataset_filter` ADD CONSTRAINT `tdfilter_feature_view_fk` FOREIGN KEY
    (`feature_view_id`) REFERENCES `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`training_dataset_feature` ADD COLUMN `feature_view_id` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`training_dataset_feature` ADD CONSTRAINT `tdf_feature_view_fk` FOREIGN KEY (`feature_view_id`)
    REFERENCES `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`feature_store_activity` ADD COLUMN `feature_view_id` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`feature_store_activity` ADD CONSTRAINT `fsa_feature_view_fk` FOREIGN KEY (`feature_view_id`) REFERENCES
    `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `start_time` TIMESTAMP NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `end_time` TIMESTAMP NULL;
ALTER TABLE `hopsworks`.`training_dataset` DROP FOREIGN KEY `hopsfs_training_dataset_fk`;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `hopsfs_training_dataset_fk`
    FOREIGN KEY (`hopsfs_training_dataset_id`) REFERENCES `hopsfs_training_dataset` (`id`)
        ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`training_dataset` DROP FOREIGN KEY `FK_656_817`;
ALTER TABLE `hopsworks`.`training_dataset` DROP INDEX `name_version`;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `FK_656_817` FOREIGN KEY (`feature_store_id`) REFERENCES
    `feature_store` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `name_version` UNIQUE (`feature_store_id`,
                                                                                 `feature_view_id`, `name`, `version`);


CREATE TABLE IF NOT EXISTS `feature_store_kafka_connector` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `bootstrap_servers` VARCHAR(1000) NOT NULL,
    `security_protocol` VARCHAR(1000) NOT NULL,
    `ssl_secret_uid` INT NULL,
    `ssl_secret_name` VARCHAR(200) NULL,
    `ssl_endpoint_identification_algorithm` VARCHAR(100) NULL,
    `options` VARCHAR(2000) NULL,
    `truststore_inode_pid` BIGINT(20) NULL,
    `truststore_inode_name` VARCHAR(255) NULL,
    `truststore_partition_id` BIGINT(20) NULL,
    `keystore_inode_pid` BIGINT(20) NULL,
    `keystore_inode_name` VARCHAR(255) NULL,
    `keystore_partition_id` BIGINT(20) NULL,
    PRIMARY KEY (`id`),
    KEY `fk_fs_storage_connector_kafka_idx` (`ssl_secret_uid`, `ssl_secret_name`),
    CONSTRAINT `fk_fs_storage_connector_kafka` FOREIGN KEY (`ssl_secret_uid`, `ssl_secret_name`) REFERENCES `hopsworks`.`secrets` (`uid`, `secret_name`) ON DELETE RESTRICT,
    CONSTRAINT `fk_fs_storage_connector_kafka_truststore` FOREIGN KEY (
        `truststore_inode_pid`,
        `truststore_inode_name`,
        `truststore_partition_id`
    ) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fk_fs_storage_connector_kafka_keystore` FOREIGN KEY (
        `keystore_inode_pid`,
        `keystore_inode_name`,
        `keystore_partition_id`
    ) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_store_connector` ADD COLUMN `kafka_id` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`feature_store_connector` ADD CONSTRAINT `fs_connector_kafka_fk` FOREIGN KEY (`kafka_id`) REFERENCES `hopsworks`.`feature_store_kafka_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`external_training_dataset`
    ADD COLUMN `inode_pid`  BIGINT(20) NOT NULL,
    ADD COLUMN `inode_name` VARCHAR(255) NOT NULL,
    ADD COLUMN `partition_id` BIGINT(20) NOT NULL,
    ADD CONSTRAINT `ext_td_inode_fk` FOREIGN KEY (`inode_pid`, `inode_name`, `partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `description` varchar(1000) COLLATE latin1_general_cs DEFAULT NULL;

-- Add StreamFeatureGroup
CREATE TABLE IF NOT EXISTS `stream_feature_group` (
                                                      `id`                             INT(11) NOT NULL AUTO_INCREMENT,
                                                      `offline_feature_group`          BIGINT(20) NOT NULL,
                                                      `online_enabled`                 TINYINT(1) NOT NULL DEFAULT 1,
                                                      PRIMARY KEY (`id`),
                                                      CONSTRAINT `stream_fg_hive_fk` FOREIGN KEY (`offline_feature_group`) REFERENCES `metastore`.`TBLS` (`TBL_ID`) ON DELETE CASCADE ON UPDATE NO ACTION
)
ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `stream_feature_group_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`feature_group` ADD KEY `stream_feature_group_fk` (`stream_feature_group_id`);
ALTER TABLE `hopsworks`.`feature_group` ADD CONSTRAINT `stream_feature_group_fk` FOREIGN KEY (`stream_feature_group_id`) REFERENCES `stream_feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`cached_feature` ADD COLUMN `stream_feature_group_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`cached_feature` ADD KEY `stream_feature_group_fk2` (`stream_feature_group_id`);
ALTER TABLE `hopsworks`.`cached_feature` ADD CONSTRAINT `stream_feature_group_fk2` FOREIGN KEY (`stream_feature_group_id`) REFERENCES `stream_feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`cached_feature_extra_constraints` ADD COLUMN `stream_feature_group_id` INT(11) NULL;

ALTER TABLE `hopsworks`.`feature_group_commit` MODIFY COLUMN `committed_on` TIMESTAMP(6) NOT NULL;

ALTER TABLE `hopsworks`.`users` DROP COLUMN `orcid`;
ALTER TABLE `hopsworks`.`users` MODIFY COLUMN `fname` varchar(30) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL;
ALTER TABLE `hopsworks`.`users` MODIFY COLUMN `lname` varchar(30) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL;

-- add gcs connector
CREATE TABLE IF NOT EXISTS `feature_store_gcs_connector` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `algorithm` VARCHAR(10) NULL,
    `bucket` VARCHAR(1000) NOT NULL,
    `encryption_secret_uid` INT NULL,
    `encryption_secret_name` VARCHAR(200) NULL,
    `key_inode_pid` BIGINT(20) NULL,
    `key_inode_name` VARCHAR(255) NULL,
    `key_partition_id` BIGINT(20) NULL,
    PRIMARY KEY (`id`),
    KEY `fk_fs_storage_connector_gcs_idx` (`encryption_secret_uid`, `encryption_secret_name`),
    CONSTRAINT `fk_fs_storage_connector_gcs` FOREIGN KEY (`encryption_secret_uid`, `encryption_secret_name`) REFERENCES `hopsworks`.`secrets` (`uid`, `secret_name`) ON DELETE RESTRICT,
    CONSTRAINT `fk_fs_storage_connector_gcs_keyfile` FOREIGN KEY (
        `key_inode_pid`,
        `key_inode_name`,
        `key_partition_id`
    ) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_store_connector`
    ADD COLUMN `gcs_id` INT(11),
    ADD CONSTRAINT `fs_connector_gcs_fk` FOREIGN KEY (`gcs_id`) REFERENCES `hopsworks`.`feature_store_gcs_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

-- Split serving resource config
ALTER TABLE `hopsworks`.`serving` RENAME COLUMN `docker_resource_config` TO `predictor_resources`;
ALTER TABLE `hopsworks`.`serving` ADD COLUMN `transformer_resources` varchar(1000) COLLATE latin1_general_cs DEFAULT NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`serving`
SET `predictor_resources` = JSON_SET(`predictor_resources`, '$.requests', CAST(`predictor_resources` as JSON), '$.limits', CAST(`predictor_resources` as JSON)),
    `predictor_resources` = JSON_REMOVE(`predictor_resources`, '$.cores', '$.memory', '$.gpus'),
    `transformer_resources` = (CASE WHEN `transformer` IS NOT NULL then `predictor_resources` else NULL end);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`jupyter_settings`
    DROP COLUMN git_backend,
    DROP COLUMN git_config_id;
DROP TABLE IF EXISTS `hopsworks`.`jupyter_git_config`;

-- Add bigquery connector
CREATE TABLE IF NOT EXISTS `feature_store_bigquery_connector`
(
    `id`                      int AUTO_INCREMENT,
    `key_inode_pid` BIGINT(20) NULL,
    `key_inode_name` VARCHAR(255) NULL,
    `key_partition_id` BIGINT(20) NULL,
    `parent_project`          varchar(1000) NOT NULL,
    `dataset`                 varchar(1000) NULL,
    `query_table`             varchar(1000) NULL,
    `query_project`           varchar(1000) NULL,
    `materialization_dataset` varchar(1000) NULL,
    `arguments`               varchar(2000) NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_fs_storage_connector_bigq_keyfile` FOREIGN KEY (
        `key_inode_pid`,
        `key_inode_name`,
        `key_partition_id`
    ) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_store_connector`
    ADD COLUMN `bigquery_id` INT,
    ADD CONSTRAINT `fs_connector_bigquery_fk` FOREIGN KEY (`bigquery_id`) REFERENCES `hopsworks`.`feature_store_bigquery_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`api_key_scope` SET `scope` = 'PYTHON_LIBRARIES' WHERE `scope` = 'PYTHON';
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`project_topics` ADD COLUMN `num_partitions` INT(11) DEFAULT NULL,
    ADD COLUMN `num_replicas` INT(11) DEFAULT NULL;

-- Data Validation Great Expectation
CREATE TABLE IF NOT EXISTS `expectation_suite` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `feature_group_id` INT(11) NOT NULL,
    `name` VARCHAR(63) NOT NULL,
    `meta` VARCHAR(1000) DEFAULT "{}",
    `data_asset_type` VARCHAR(50),
    `ge_cloud_id` VARCHAR(200),
    `run_validation` BOOLEAN DEFAULT TRUE,
    `validation_ingestion_policy` VARCHAR(25),
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    CONSTRAINT `feature_group_suite_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `expectation` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `expectation_suite_id` INT(11) NOT NULL,
    `expectation_type` VARCHAR(150) NOT NULL,
    `kwargs` VARCHAR(1000) NOT NULL,
    `meta` VARCHAR(1000) DEFAULT "{}",
    PRIMARY KEY (`id`),
    CONSTRAINT `suite_fk` FOREIGN KEY (`expectation_suite_id`) REFERENCES `expectation_suite` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `great_expectation` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `kwargs_template` VARCHAR(1000) NOT NULL,
    `expectation_type` VARCHAR(150) NOT NULL,
    UNIQUE KEY `unique_great_expectation` (`expectation_type`),
    PRIMARY KEY (`id`)
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `validation_report` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `feature_group_id` INT(11) NOT NULL,
    `success` BOOLEAN NOT NULL,
    `validation_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `evaluation_parameters` VARCHAR(1000) DEFAULT "{}",
    `meta` VARCHAR(2000) NULL DEFAULT "{}",
    `statistics` VARCHAR(1000) NOT NULL,
    `inode_pid` BIGINT(20) NOT NULL,
    `inode_name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL,
    `partition_id` BIGINT(20) NOT NULL,
    `ingestion_result` VARCHAR(8) NOT NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT `feature_group_report_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `inode_result_fk` FOREIGN KEY (`inode_pid`,`inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `validation_result` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `validation_report_id` INT(11) NOT NULL,
    `expectation_id` INT(11) NOT NULL,
    `success` BOOLEAN NOT NULL,
    `result` VARCHAR(1000) NOT NULL,
    `meta` VARCHAR(1000) DEFAULT "{}",
    `expectation_config` VARCHAR(2150) NOT NULL,
    `exception_info` VARCHAR(1000) DEFAULT "{}",
    PRIMARY KEY (`id`),
    KEY (`expectation_id`),
    CONSTRAINT `report_fk_validation_result` FOREIGN KEY (`validation_report_id`) REFERENCES `validation_report` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `batching_configuration` varchar(255) COLLATE latin1_general_cs DEFAULT NULL;
SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`serving`
SET `batching_configuration` =  (CASE WHEN `enable_batching` = '0' OR enable_batching IS NULL  then
    '{"batchingEnabled":false}'
    else
    '{"batchingEnabled":true}'
    end);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`serving` DROP COLUMN `enable_batching`;

ALTER TABLE `hopsworks`.`api_key_scope` DROP FOREIGN KEY `fk_api_key_scope_1`;
ALTER TABLE `hopsworks`.`api_key_scope` ADD CONSTRAINT `fk_api_key_scope_1`
  FOREIGN KEY (`api_key`)
  REFERENCES `hopsworks`.`api_key` (`id`)
  ON DELETE CASCADE
  ON UPDATE NO ACTION;

DROP TABLE IF EXISTS `feature_store_expectation_rule`;
DROP TABLE IF EXISTS `validation_rule`;
DROP TABLE IF EXISTS `feature_group_rule`;
ALTER TABLE `hopsworks`.`feature_group_commit` DROP FOREIGN KEY `fgc_fk_fgv`, DROP COLUMN `validation_id`;
ALTER TABLE `hopsworks`.`feature_store_activity` DROP FOREIGN KEY `fs_act_val_fk`, DROP COLUMN `validation_id`;
DROP TABLE IF EXISTS `feature_group_validation`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `validation_type`;
