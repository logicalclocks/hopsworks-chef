DROP TABLE IF EXISTS `default_job_configuration`;
ALTER TABLE `hopsworks`.`validation_rule` DROP COLUMN `feature_type`;
ALTER TABLE `hopsworks`.`serving` DROP COLUMN `deployed`;
ALTER TABLE `hopsworks`.`serving` DROP COLUMN `revision`;

DROP TABLE IF EXISTS `alert_manager_config`;
DROP TABLE IF EXISTS `job_alert`;
DROP TABLE IF EXISTS `feature_group_alert`;
DROP TABLE IF EXISTS `project_service_alert`;