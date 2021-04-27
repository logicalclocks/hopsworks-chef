DROP TABLE IF EXISTS `default_job_configuration`;
ALTER TABLE `hopsworks`.`serving` DROP COLUMN `deployed`;
ALTER TABLE `hopsworks`.`serving` DROP COLUMN `revision`;
ALTER TABLE `hopsworks`.`validation_rule` DROP COLUMN `feature_type`;