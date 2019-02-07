ALTER TABLE `hopsworks`.`dataset` DROP FOREIGN KEY `featurestore_fk`;
ALTER TABLE `hopsworks`.`dataset` DROP COLUMN `feature_store_id`;

DROP TABLE IF EXISTS `featurestore_dependency`;
DROP TABLE IF EXISTS `training_dataset_feature`;
DROP TABLE IF EXISTS `feature_statistic`;
DROP TABLE IF EXISTS `feature_group`;
DROP TABLE IF EXISTS `training_dataset`
DROP TABLE IF EXISTS `feature_store`;

ALTER TABLE `hopsworks`.`executions` DROP INDEX `submission_time_idx`, DROP INDEX `state_idxs`, DROP INDEX `finalStatus_idx`, DROP INDEX `progress_idx`;
ALTER TABLE `hopsworks`.`jobs` DROP INDEX `creation_time_project_idx`, DROP INDEX `type_project_id_idx`, DROP INDEX `creator_project_idx`;
