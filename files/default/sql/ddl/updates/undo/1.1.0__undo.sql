ALTER TABLE `hopsworks`.`jobs` CHANGE COLUMN `json_config` `json_config` TEXT COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`jupyter_settings` CHANGE COLUMN `job_config` `json_config` TEXT COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`message` CHANGE COLUMN `content` `content` TEXT COLLATE latin1_general_cs NOT NULL;

ALTER TABLE hopsworks.`jupyter_settings` DROP COLUMN `python_kernel`;
ALTER TABLE hopsworks.`jupyter_settings` DROP COLUMN `docker_config`;

