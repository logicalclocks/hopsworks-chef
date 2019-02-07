--
--  Feature store tables in Hopsworks
--
CREATE TABLE IF NOT EXISTS `feature_store` (
  `id`         INT(11)    NOT NULL AUTO_INCREMENT,
  `project_id` INT(11)    NOT NULL,
  `created`    TIMESTAMP           DEFAULT CURRENT_TIMESTAMP,
  `hive_db_id` BIGINT(20) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`hive_db_id`) REFERENCES `metastore`.`DBS` (`DB_ID`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_group` (
  `id`                      INT(11)    NOT NULL AUTO_INCREMENT,
  `feature_store_id`        INT(11)    NOT NULL,
  `hdfs_user_id`            INT(11)    NOT NULL,
  `created`                 TIMESTAMP           DEFAULT CURRENT_TIMESTAMP,
  `creator`                 INT(11)    NOT NULL,
  `job_id`                  INT(11)    NULL,
  `hive_tbl_id`             BIGINT(20) NOT NULL,
  `version`                 INT(11)    NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`feature_store_id`) REFERENCES `feature_store` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`)
    ON DELETE SET NULL
    ON UPDATE NO ACTION,
  FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`hive_tbl_id`) REFERENCES `metastore`.`TBLS` (`TBL_ID`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`creator`) REFERENCES `users` (`uid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `training_dataset` (
  `id`                      INT(11)      NOT NULL AUTO_INCREMENT,
  `feature_store_id`        INT(11)      NOT NULL,
  `hdfs_user_id`            INT(11)      NOT NULL,
  `created`                 TIMESTAMP             DEFAULT CURRENT_TIMESTAMP,
  `creator`                 INT(11)      NOT NULL,
  `job_id`                  INT(11)      NULL,
  `version`                 INT(11)      NOT NULL,
  `data_format`             VARCHAR(128) NOT NULL,
  `training_dataset_folder` INT(11)      NOT NULL,
  `inode_pid` BIGINT(20) NOT NULL,
  `inode_name`              VARCHAR(255) NOT NULL,
  `partition_id`            BIGINT(20)      NOT NULL,
  `description`             VARCHAR(10000)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`feature_store_id`) REFERENCES `feature_store` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`)
    ON DELETE SET NULL
    ON UPDATE NO ACTION,
  FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`creator`) REFERENCES `users` (`uid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (`training_dataset_folder`) REFERENCES `dataset` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`inode_pid`, `inode_name`, `partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `featurestore_statistic` (
  `id`               INT(11) NOT NULL AUTO_INCREMENT,
  `feature_group_id` INT(11) DEFAULT NULL,
  `training_dataset_id` INT(11) DEFAULT NULL,
  `name`             VARCHAR(500)   DEFAULT NULL,
  `statistic_type`   INT(11) NOT NULL DEFAULT '0',
  `value`            VARCHAR(13300) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `featurestore_dependency` (
  `id`               INT(11) NOT NULL AUTO_INCREMENT,
  `feature_group_id` INT(11) DEFAULT NULL,
  `training_dataset_id` INT(11) DEFAULT NULL,
  `inode_pid` BIGINT(20) NOT NULL,
  `inode_name`              VARCHAR(255) NOT NULL,
  `partition_id`            BIGINT(20)      NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`inode_pid`, `inode_name`, `partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `training_dataset_feature` (
  `id`               INT(11) NOT NULL AUTO_INCREMENT,
  `training_dataset_id` INT(11) NOT NULL,
  `name`             VARCHAR(1000) NOT NULL,
  `primary_column`          tinyint(1) NOT NULL DEFAULT '0',
  `description`             VARCHAR(10000) NOT NULL,
  `type`             VARCHAR(1000) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

ALTER TABLE `hopsworks`.`dataset`
  ADD COLUMN `feature_store_id` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`dataset`
  ADD FOREIGN KEY `featurestore_fk` (`feature_store_id`) REFERENCES `feature_store` (`id`)
  ON DELETE SET NULL
  ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`jobs` ADD INDEX `creation_time_project_idx` (`creation_time` DESC, `project_id`), ADD INDEX `type_project_id_idx` (`type`, `project_id`), ADD INDEX `creator_project_idx` (`creator`, `project_id`);
ALTER TABLE `hopsworks`.`executions` ADD INDEX `submission_time_idx` (`submission_time` DESC, `job_id`), ADD INDEX `state_idx` (`state`, `job_id`), ADD INDEX `finalStatus_idx` (`finalStatus`, `job_id`), ADD INDEX `progress_idx` (`progress` DESC, `job_id`);
