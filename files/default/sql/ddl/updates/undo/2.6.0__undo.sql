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