-- HWORKS-987
ALTER TABLE `hopsworks`.`model_version` ADD CONSTRAINT `model_version_key` UNIQUE (`model_id`,`version`);
ALTER TABLE `hopsworks`.`model_version` DROP PRIMARY KEY;
ALTER TABLE `hopsworks`.`model_version` ADD COLUMN id int(11) AUTO_INCREMENT PRIMARY KEY;

-- FSTORE-1190
ALTER TABLE `hopsworks`.`embedding_feature`
    ADD COLUMN `model_version_id` INT(11) NULL;

ALTER TABLE `hopsworks`.`embedding_feature`
    ADD CONSTRAINT `embedding_feature_model_version_fk` FOREIGN KEY (`model_version_id`) REFERENCES `model_version` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `api_protocol` TINYINT(1) NOT NULL DEFAULT '0';

-- FSTORE-1096
ALTER TABLE `hopsworks`.`feature_store_jdbc_connector`
    ADD COLUMN `secret_uid` INT DEFAULT NULL,
    ADD COLUMN `secret_name` VARCHAR(200) DEFAULT NULL;

-- FSTORE-1248
ALTER TABLE `hopsworks`.`executions`
    ADD COLUMN `notebook_out_path` varchar(255) COLLATE latin1_general_cs DEFAULT NULL;

CREATE TABLE IF NOT EXISTS `hopsworks`.`model_link` (
  `id` int NOT NULL AUTO_INCREMENT,
  `model_version_id` int(11) NOT NULL,
  `parent_training_dataset_id` int(11),
  `parent_feature_store` varchar(100) NOT NULL,
  `parent_feature_view_name` varchar(63) NOT NULL,
  `parent_feature_view_version` int(11) NOT NULL,
  `parent_training_dataset_version` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `link_unique` (`model_version_id`, `parent_training_dataset_id`),
  KEY `model_version_id_fkc` (`model_version_id`),
  KEY `parent_training_dataset_id_fkc` (`parent_training_dataset_id`),
  CONSTRAINT `model_version_id_fkc` FOREIGN KEY (`model_version_id`) REFERENCES `hopsworks`.`model_version` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `training_dataset_parent_fkc` FOREIGN KEY (`parent_training_dataset_id`) REFERENCES `hopsworks`.`training_dataset` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- FSTORE-920
ALTER TABLE `hopsworks`.`feature_store_jdbc_connector`
    ADD `driver_path` VARCHAR(2000) DEFAULT NULL;

-- HWORKS-1235
ALTER TABLE `hopsworks`.`serving` ADD COLUMN `deployed_by` int(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`serving` ADD KEY `deployed_by_fk` (`deployed_by`);
ALTER TABLE `hopsworks`.`serving` ADD CONSTRAINT `deployed_by_fk_serving` FOREIGN KEY (`deployed_by`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION;

-- HWORKS-927
ALTER TABLE `hopsworks`.`serving`
    DROP COLUMN `model_path`,
    DROP COLUMN `artifact_version`,
    DROP COLUMN `predictor`,
    DROP COLUMN `transformer`,
    DROP COLUMN `model_name`,
    DROP COLUMN `model_version`,
    DROP COLUMN `model_framework`,
    DROP COLUMN `batching_configuration`,
    DROP COLUMN `optimized`,
    DROP COLUMN `instances`,
    DROP COLUMN `transformer_instances`,
    DROP COLUMN `model_server`,
    DROP COLUMN `predictor_resources`,
    DROP COLUMN `transformer_resources`;

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `specification` int(11) NOT NULL,
                                  ADD COLUMN `canary_spec` int(11) DEFAULT NULL,
                                  ADD COLUMN `canary_traffic_percentage`  TINYINT DEFAULT NULL;
ALTER TABLE `hopsworks`.`serving` ADD CONSTRAINT unique_specification UNIQUE (specification);
ALTER TABLE `hopsworks`.`serving` ADD CONSTRAINT unique_canary_spec UNIQUE (canary_spec);

CREATE TABLE `serving_spec` (
                                `id` int(11) NOT NULL AUTO_INCREMENT,
                                `model_path` varchar(255) COLLATE latin1_general_cs NOT NULL,
                                `artifact_version` int(11) DEFAULT NULL,
                                `predictor` varchar(255) COLLATE latin1_general_cs DEFAULT NULL,
                                `transformer` varchar(255) COLLATE latin1_general_cs DEFAULT NULL,
                                `model_name` varchar(255) COLLATE latin1_general_cs NOT NULL,
                                `model_version` int(11) NOT NULL,
                                `model_framework` int(11) NOT NULL,
                                `batching_configuration` varchar(255) COLLATE latin1_general_cs DEFAULT NULL,
                                `optimized` tinyint(4) NOT NULL DEFAULT '0',
                                `instances` int(11) NOT NULL DEFAULT '0',
                                `transformer_instances` int(11) DEFAULT NULL,
                                `model_server` int(11) NOT NULL DEFAULT '0',
                                `revision` varchar(8) DEFAULT NULL,
                                `predictor_resources` varchar(1000) COLLATE latin1_general_cs DEFAULT NULL,
                                `transformer_resources` varchar(1000) COLLATE latin1_general_cs DEFAULT NULL,
                                PRIMARY KEY (`id`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`serving` ADD CONSTRAINT `specification_fk` FOREIGN KEY (`specification`) REFERENCES `serving_spec` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`serving` ADD CONSTRAINT `canary_spec_fk` FOREIGN KEY (`canary_spec`) REFERENCES `serving_spec` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
