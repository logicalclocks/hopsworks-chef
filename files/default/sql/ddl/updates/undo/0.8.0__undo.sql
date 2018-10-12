ALTER TABLE `hopsworks`.`dataset` DROP FOREIGN KEY `featurestore_fk`;
ALTER TABLE `hopsworks`.`dataset` DROP COLUMN `feature_store_id`;

DROP TABLE IF EXISTS `featurestore_dependency`;
DROP TABLE IF EXISTS `training_dataset_feature`;
DROP TABLE IF EXISTS `feature_statistic`;
DROP TABLE IF EXISTS `feature_group`;
DROP TABLE IF EXISTS `training_dataset`
DROP TABLE IF EXISTS `feature_store`;