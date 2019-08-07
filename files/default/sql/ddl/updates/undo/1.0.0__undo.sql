DROP TABLE IF EXISTS `secrets`;

ALTER TABLE `hopsworks`.`users` DROP COLUMN `validation_key_updated`;
ALTER TABLE `hopsworks`.`users` DROP COLUMN `validation_key_type`;
ALTER TABLE `hopsworks`.`users` CHANGE COLUMN `activated` `activated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

DROP TABLE IF EXISTS `hopsworks`.`api_key`;
DROP TABLE IF EXISTS `hopsworks`.`api_key_scope`;


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

/*
  Move back columns from cached_feature_group to feature_group
*/
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `hive_tbl_id` BIGINT(20) NOT NULL;

-- Move hive_tbl_id
UPDATE `hopsworks`.`feature_group` INNER JOIN `hopsworks`.`cached_feature_group`
    ON `feature_group`.`cached_feature_group_id` = `cached_feature_group`.`id`
SET `feature_group`.`hive_tbl_id` = `cached_feature_group`.`offline_feature_group`;

-- Add foreign key
ALTER TABLE `hopsworks`.`feature_group` ADD CONSTRAINT `hive_table_fk`
                                                FOREIGN KEY (`hive_tbl_id`) REFERENCES
                                               `metastore`.`TBLS` (`TBL_ID`)
                                               ON DELETE CASCADE
                                               ON UPDATE NO ACTION;

/*
  Move columns from cached_feature_group to feature_group - COMPLETE
*/

/*
  Move back columns from hopsfs_training_dataset to training_dataset
*/
ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `training_dataset_folder` INT(11) NOT NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `inode_pid` BIGINT(20) NOT NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `inode_name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `partition_id` BIGINT(20) NOT NULL;

-- Add foreign key
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `training_dataset_inode_fk`
                                                FOREIGN KEY (`inode_pid`, `inode_name`, `partition_id`)
                                                REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
                                                ON DELETE CASCADE
                                                ON UPDATE NO ACTION;

-- Move back Inode
UPDATE `hopsworks`.`training_dataset` INNER JOIN `hopsworks`.`hopsfs_training_dataset`
    ON `training_dataset`.`hopsfs_training_dataset_id` = `hopsfs_training_dataset`.`id`
    SET `training_dataset`.`inode_name` = `hopsfs_training_dataset`.`inode_name`,
    `training_dataset`.`partition_id` = `hopsfs_training_dataset`.`partition_id`,
    `training_dataset`.`inode_pid` = `hopsfs_training_dataset`.`inode_pid`;


-- Move back dataset column from hopsfs_connector to training_dataset
UPDATE `hopsworks`.`training_dataset` INNER JOIN `hopsworks`.`feature_store_hopsfs_connector`
    INNER JOIN `hopsworks`.`hopsfs_training_dataset`
    ON `hopsfs_training_dataset`.`hopsfs_connector_id` = `feature_store_hopsfs_connector`.`id`
    AND `training_dataset`.`hopsfs_training_dataset_id` = `hopsfs_training_dataset`.`id`
    SET `training_dataset`.`training_dataset_folder` = `feature_store_hopsfs_connector`.`hopsfs_dataset`;

-- Add foreign key
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `training_dataset_dataset_fk`
                                                FOREIGN KEY (`training_dataset_folder`)
                                                REFERENCES `dataset` (`id`)
                                                ON DELETE CASCADE
                                                ON UPDATE NO ACTION;

/*
  Move columns from hopsfs_training_dataset to training_dataset - COMPLETE
*/

ALTER TABLE `hopsworks`.`feature_store_feature` RENAME TO `training_dataset_feature`;
ALTER TABLE `hopsworks`.`training_dataset_feature` DROP FOREIGN KEY `on_demand_feature_group_fk`;
ALTER TABLE `hopsworks`.`training_dataset_feature` DROP COLUMN `on_demand_feature_group_id`;

ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `feature_group_type`;

ALTER TABLE `hopsworks`.`feature_group` DROP FOREIGN KEY `on_demand_feature_group_fk`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `on_demand_feature_group_id`;

ALTER TABLE `hopsworks`.`feature_group` DROP FOREIGN KEY `cached_feature_group_fk`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `cached_feature_group_id`;


ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `job_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`feature_group` ADD CONSTRAINT `featuregroup_job_fk`
                                                FOREIGN KEY (`job_id`) REFERENCES
                                               `hopsworks`.`jobs`(`id`)
                                               ON DELETE SET NULL
                                               ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `training_dataset_type`;

ALTER TABLE `hopsworks`.`training_dataset` DROP FOREIGN KEY `external_training_dataset_fk`;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `external_training_dataset_id`;

ALTER TABLE `hopsworks`.`training_dataset` DROP FOREIGN KEY `hopsfs_training_dataset_fk`;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `hopsfs_training_dataset_id`;

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `job_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `training_dataset_job_fk`
                                                FOREIGN KEY (`job_id`) REFERENCES
                                               `hopsworks`.`jobs`(`id`)
                                               ON DELETE SET NULL
                                               ON UPDATE NO ACTION;



DROP TABLE IF EXISTS `hopsworks`.`feature_store_job`;
DROP TABLE IF EXISTS `hopsworks`.`on_demand_feature_group`;
DROP TABLE IF EXISTS `hopsworks`.`cached_feature_group`;
DROP TABLE IF EXISTS `hopsworks`.`hopsfs_training_dataset`;
DROP TABLE IF EXISTS `hopsworks`.`external_training_dataset`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_jdbc_connector`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_s3_connector`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_hopsfs_connector`;
