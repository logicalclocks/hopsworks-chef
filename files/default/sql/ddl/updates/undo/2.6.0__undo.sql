-- Feature view table
ALTER TABLE `hopsworks`.`training_dataset` DROP CONSTRAINT `td_model_feature_fk`, DROP COLUMN `model_feature_id`;
ALTER TABLE `hopsworks`.`training_dataset_join` DROP CONSTRAINT `tdj_model_feature_fk`, DROP COLUMN model_feature_id;
ALTER TABLE `hopsworks`.`training_dataset_feature` DROP CONSTRAINT `tdf_model_feature_fk`, DROP COLUMN model_feature_id;
ALTER TABLE `hopsworks`.`feature_store_activity` DROP CONSTRAINT `fsa_model_feature_fk`, DROP COLUMN model_feature_id;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `start_time`, DROP COLUMN `end_time`;
DROP TABLE IF EXISTS `hopsworks`.`model_feature`;