-- Feature view table
ALTER TABLE `hopsworks`.`training_dataset` DROP CONSTRAINT `td_feature_view_fk`, DROP COLUMN `feature_view_id`;
ALTER TABLE `hopsworks`.`training_dataset_join` DROP CONSTRAINT `tdj_feature_view_fk`, DROP COLUMN feature_view_id;
ALTER TABLE `hopsworks`.`training_dataset_feature` DROP CONSTRAINT `tdf_feature_view_fk`, DROP COLUMN feature_view_id;
ALTER TABLE `hopsworks`.`feature_store_activity` DROP CONSTRAINT `fsa_feature_view_fk`, DROP COLUMN feature_view_id;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `start_time`, DROP COLUMN `end_time`;
DROP TABLE IF EXISTS `hopsworks`.`feature_view`;