ALTER TABLE `hopsworks`.`validation_rule` MODIFY COLUMN description VARCHAR(100) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`validation_rule` DROP INDEX `unique_validation_rule`;
ALTER TABLE `hopsworks`.`validation_rule` ADD CONSTRAINT `unique_validation_rule` UNIQUE KEY (`name`,`predicate`,`accepted_type`);

ALTER TABLE `hopsworks`.`serving` DROP COLUMN `model_name`;
ALTER TABLE `hopsworks`.`serving` DROP COLUMN `predictor`;

ALTER TABLE `hopsworks`.`api_key` DROP COLUMN `reserved`;

ALTER TABLE `hopsworks`.`executions` ADD CONSTRAINT `FK_347_365`  FOREIGN KEY (`job_id`) REFERENCES `hopsworks`.`jobs` (`id`) ON DELETE CASCADE;

DROP TABLE `hopsworks`.`cached_feature`;

ALTER TABLE `hopsworks`.`on_demand_feature_group` MODIFY COLUMN `query` VARCHAR(11000) COLLATE latin1_general_cs DEFAULT NULL;

DROP TABLE IF EXISTS `hopsworks`.`oauth_token`;

ALTER TABLE `hopsworks`.`oauth_login_state` RENAME COLUMN `access_token` TO `token`;
ALTER TABLE `hopsworks`.`oauth_login_state` DROP COLUMN `id_token`;
ALTER TABLE `hopsworks`.`oauth_login_state` DROP COLUMN `refresh_token`;

ALTER TABLE `hopsworks`.`feature_store_statistic` DROP COLUMN `for_transformation`;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `train_split`;

-- training dataset filter table
DROP TABLE IF EXISTS `hopsworks`.`training_dataset_filter`;
DROP TABLE IF EXISTS `hopsworks`.`training_dataset_filter_condition`;

ALTER TABLE `hopsworks`.`variables` DROP COLUMN `hide`;

ALTER TABLE `hopsworks`.`conda_commands` ADD COLUMN `user` varchar(52) COLLATE latin1_general_cs NOT NULL;

DROP TABLE IF EXISTS `git_executions`;

DROP TABLE IF EXISTS `git_repositories`;

DROP TABLE IF EXISTS `git_commits`;

DROP TABLE IF EXISTS `git_repository_remotes`;
