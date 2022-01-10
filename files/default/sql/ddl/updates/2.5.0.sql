ALTER TABLE `hopsworks`.`validation_rule` MODIFY COLUMN description VARCHAR(200) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`validation_rule` DROP INDEX `unique_validation_rule`;
ALTER TABLE `hopsworks`.`validation_rule` ADD CONSTRAINT `unique_validation_rule` UNIQUE KEY (`name`);

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `model_name` varchar(255) COLLATE latin1_general_cs NOT NULL AFTER `transformer`;

ALTER TABLE `hopsworks`.`api_key` ADD COLUMN `reserved` tinyint(1) DEFAULT '0';

-- Set model_name column, parse the model path on format /Projects/{project}/Models/{model} and get the model name
SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`serving`
SET `model_name` = (SELECT REPLACE(SUBSTRING(SUBSTRING_INDEX(`model_path`, '/', 5), LENGTH(SUBSTRING_INDEX(`model_path`, '/', 4)) + 1), '/', ''));
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`executions` DROP FOREIGN KEY `FK_347_365`;

CREATE TABLE `cached_feature` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cached_feature_group_id` int(11) NULL,
  `name` varchar(63) COLLATE latin1_general_cs NOT NULL,
  `description` varchar(256) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `cached_feature_group_fk` (`cached_feature_group_id`),
  CONSTRAINT `cached_feature_group_fk2` FOREIGN KEY (`cached_feature_group_id`) REFERENCES `cached_feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`on_demand_feature_group` MODIFY COLUMN `query` VARCHAR(26000) COLLATE latin1_general_cs DEFAULT NULL;

CREATE TABLE `hopsworks`.`oauth_token` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `id_token` varchar(8000) COLLATE latin1_general_cs NOT NULL,
  `access_token` varchar(8000) COLLATE latin1_general_cs DEFAULT NULL,
  `refresh_token` varchar(8000) COLLATE latin1_general_cs DEFAULT NULL,
  `login_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `login_state_UNIQUE` (`user_id`),
  KEY `fk_oauth_token_user` (`user_id`),
  CONSTRAINT `fk_oauth_token_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`uid`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`oauth_login_state` ADD COLUMN `id_token` VARCHAR(8000) NULL;
ALTER TABLE `hopsworks`.`oauth_login_state` ADD COLUMN `refresh_token` VARCHAR(8000) NULL;
ALTER TABLE `hopsworks`.`oauth_login_state` RENAME COLUMN `token` TO `access_token`;

ALTER TABLE `hopsworks`.`feature_store_statistic` ADD COLUMN `for_transformation` TINYINT(1) DEFAULT '0';

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `train_split` VARCHAR(63) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`variables` ADD COLUMN `hide` TINYINT NOT NULL DEFAULT 0;
ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN `user`;
