ALTER TABLE `hopsworks`.`jobs` CHANGE COLUMN `json_config` `json_config` VARCHAR(12500) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`jupyter_settings` CHANGE COLUMN `json_config` `job_config` VARCHAR(11000) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`message` CHANGE COLUMN `content` `content` VARCHAR(11000) COLLATE latin1_general_cs NOT NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`users` SET `tours_state`=0;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE hopsworks.`jupyter_settings` ADD COLUMN `python_kernel` tinyint(1) DEFAULT 1 AFTER `git_config_id`;
ALTER TABLE hopsworks.`jupyter_settings` ADD COLUMN `docker_config` VARCHAR(1000) COLLATE latin1_general_cs DEFAULT NULL AFTER `job_config`;