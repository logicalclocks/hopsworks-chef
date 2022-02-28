-- Feature view table
ALTER TABLE `hopsworks`.`training_dataset` DROP FOREIGN KEY `td_feature_view_fk`, DROP COLUMN `feature_view_id`;
ALTER TABLE `hopsworks`.`training_dataset_join` DROP FOREIGN KEY `tdj_feature_view_fk`, DROP COLUMN feature_view_id;
ALTER TABLE `hopsworks`.`training_dataset_feature` DROP FOREIGN KEY `tdf_feature_view_fk`, DROP COLUMN feature_view_id;
ALTER TABLE `hopsworks`.`feature_store_activity` DROP FOREIGN KEY `fsa_feature_view_fk`, DROP COLUMN feature_view_id;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `start_time`, DROP COLUMN `end_time`;
DROP TABLE IF EXISTS `hopsworks`.`feature_view`;

ALTER TABLE `hopsworks`.`external_training_dataset`
    DROP FOREIGN KEY `ext_td_inode_fk`,
    DROP COLUMN `inode_pid`,
    DROP COLUMN `inode_name`,
    DROP COLUMN `partition_id`;
