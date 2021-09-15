CREATE TABLE IF NOT EXISTS `default_job_configuration` (
  `project_id` int(11) NOT NULL,
  `type` varchar(128) COLLATE latin1_general_cs NOT NULL,
  `config` VARCHAR(12500) COLLATE latin1_general_cs DEFAULT NULL,
  PRIMARY KEY (`project_id`, `type`),
  CONSTRAINT `FK_JOBCONFIG_PROJECT` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`validation_rule` ADD COLUMN `feature_type` VARCHAR(45) COLLATE latin1_general_cs DEFAULT NULL AFTER `accepted_type`;

CREATE TABLE IF NOT EXISTS `alert_manager_config` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content` mediumblob NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `job_alert` (
  `id` int NOT NULL AUTO_INCREMENT,
  `job_id` int NOT NULL,
  `status` varchar(45) NOT NULL,
  `type` varchar(45) NOT NULL,
  `severity` varchar(45) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_job_alert` (`job_id`,`status`),
  KEY `fk_job_alert_2_idx` (`job_id`),
  CONSTRAINT `fk_job_alert_2` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE `feature_group_alert` (
  `id` int NOT NULL AUTO_INCREMENT,
  `feature_group_id` int NOT NULL,
  `status` varchar(45) COLLATE latin1_general_cs NOT NULL,
  `type` varchar(45) COLLATE latin1_general_cs NOT NULL,
  `severity` varchar(45) COLLATE latin1_general_cs NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_feature_group_alert` (`feature_group_id`,`status`),
  KEY `fk_feature_group_alert_2_idx` (`feature_group_id`),
  CONSTRAINT `fk_feature_group_alert_2` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE `project_service_alert` (
  `id` int NOT NULL AUTO_INCREMENT,
  `project_id` int NOT NULL,
  `service` VARCHAR(32) COLLATE latin1_general_cs NOT NULL,
  `status` varchar(45) COLLATE latin1_general_cs NOT NULL,
  `type` varchar(45) COLLATE latin1_general_cs NOT NULL,
  `severity` varchar(45) COLLATE latin1_general_cs NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_project_service_alert` (`project_id`,`status`),
  KEY `fk_project_service_2_idx` (`project_id`),
  CONSTRAINT `fk_project_service_alert_2` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `transformation_function` (
  `id`                                INT(11)         NOT NULL AUTO_INCREMENT,
  `inode_pid`                         BIGINT(20)      NOT NULL,
  `inode_name`                        VARCHAR(255)    NOT NULL,
  `partition_id`                      BIGINT(20)      NOT NULL,
  `name`                              VARCHAR(255)    NOT NULL,
  `output_type`                       varchar(32)     NOT NULL,
  `version`                           INT(11)         NOT NULL,
  `feature_store_id`                  INT(11)         NOT NULL,
  `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `creator` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `inode_fn_fk` FOREIGN KEY (`inode_pid`, `inode_name`, `partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `feature_store_fn_fk` FOREIGN KEY (`feature_store_id`) REFERENCES `feature_store` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `creator_fn_fk` FOREIGN KEY (`creator`) REFERENCES `users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

ALTER TABLE `hopsworks`.`training_dataset_feature` ADD COLUMN `transformation_function` int(11) DEFAULT NULL,
  ADD CONSTRAINT `tfn_fk_tdf` FOREIGN KEY (`transformation_function`) REFERENCES `hopsworks`.`transformation_function` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`training_dataset_join` ADD COLUMN `prefix` VARCHAR(63) NULL;

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `docker_resource_config` varchar(1000) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `schemas` MODIFY COLUMN `schema` VARCHAR(29000) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL;

ALTER TABLE `hopsworks`.`serving` RENAME COLUMN `artifact_path` TO `model_path`;
ALTER TABLE `hopsworks`.`serving` RENAME COLUMN `version` TO `model_version`;
ALTER TABLE `hopsworks`.`serving` ADD COLUMN `artifact_version` int(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`serving` ADD COLUMN `transformer` varchar(255) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`serving` ADD COLUMN `transformer_instances` int(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`serving` ADD COLUMN `inference_logging` int(11) DEFAULT NULL;
