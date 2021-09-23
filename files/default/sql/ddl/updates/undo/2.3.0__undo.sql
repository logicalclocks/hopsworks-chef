DROP TABLE IF EXISTS `default_job_configuration`;
ALTER TABLE `hopsworks`.`validation_rule` DROP COLUMN `feature_type`;

DROP TABLE IF EXISTS `alert_manager_config`;
DROP TABLE IF EXISTS `job_alert`;
DROP TABLE IF EXISTS `feature_group_alert`;
DROP TABLE IF EXISTS `project_service_alert`;

ALTER TABLE `hopsworks`.`training_dataset_feature` DROP FOREIGN KEY `tfn_fk_tdf`, DROP COLUMN `transformation_function`;
DROP TABLE `hopsworks`.`transformation_function`;

ALTER TABLE `hopsworks`.`training_dataset_join` DROP COLUMN `prefix`;

ALTER TABLE `hopsworks`.`serving` DROP COLUMN `docker_resource_config`;

ALTER TABLE `schemas` MODIFY COLUMN `schema` VARCHAR(10000) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL;

ALTER TABLE `hopsworks`.`serving` RENAME COLUMN `model_path` TO `artifact_path`;
ALTER TABLE `hopsworks`.`serving` RENAME COLUMN `model_version` TO `version`;
ALTER TABLE `hopsworks`.`serving` DROP COLUMN `artifact_version`;
ALTER TABLE `hopsworks`.`serving` DROP COLUMN `transformer`;
ALTER TABLE `hopsworks`.`serving` DROP COLUMN `transformer_instances`;
ALTER TABLE `hopsworks`.`serving` DROP COLUMN `inference_logging`;
