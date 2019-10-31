ALTER TABLE `hopsworks`.`jobs` CHANGE COLUMN `json_config` `json_config` VARCHAR(12500) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`jupyter_settings` CHANGE COLUMN `json_config` `json_config` VARCHAR(12500) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`message` CHANGE COLUMN `content` `content` VARCHAR(11000) COLLATE latin1_general_cs NOT NULL;