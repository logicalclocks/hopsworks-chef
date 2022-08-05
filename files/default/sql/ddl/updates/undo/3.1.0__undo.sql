-- time series split
ALTER TABLE `hopsworks`.`training_dataset_split` DROP COLUMN `split_type`;
ALTER TABLE `hopsworks`.`training_dataset_split` DROP COLUMN `start_time`;
ALTER TABLE `hopsworks`.`training_dataset_split` DROP COLUMN `end_Time`;
ALTER TABLE `hopsworks`.`training_dataset_split` MODIFY COLUMN `percentage` float NOT NULL;
