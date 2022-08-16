-- time series split
ALTER TABLE `hopsworks`.`training_dataset_split` DROP COLUMN `split_type`;
ALTER TABLE `hopsworks`.`training_dataset_split` DROP COLUMN `start_time`;
ALTER TABLE `hopsworks`.`training_dataset_split` DROP COLUMN `end_Time`;
ALTER TABLE `hopsworks`.`training_dataset_split` MODIFY COLUMN `percentage` float NOT NULL;

DROP TABLE IF EXISTS `hopsworks`.`feature_group_link`;
DROP TABLE IF EXISTS `hopsworks`.`feature_view_link`;