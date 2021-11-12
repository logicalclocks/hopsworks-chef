ALTER TABLE `hopsworks`.`validation_rule` MODIFY COLUMN description VARCHAR(200) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`validation_rule` DROP INDEX `unique_validation_rule`;
ALTER TABLE `hopsworks`.`validation_rule` ADD CONSTRAINT `unique_validation_rule` UNIQUE KEY (`name`);

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `model_name` varchar(255) COLLATE latin1_general_cs NOT NULL AFTER `transformer`;

-- Set model_name column, parse the model path on format /Projects/{project}/Models/{model} and get the model name
SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`serving`
SET `model_name` = (SELECT REPLACE(SUBSTRING(SUBSTRING_INDEX(`model_path`, '/', 5), LENGTH(SUBSTRING_INDEX(`model_path`, '/', 4)) + 1), '/', ''));
SET SQL_SAFE_UPDATES = 1;