ALTER TABLE `hopsworks`.`conda_commands` ADD CONSTRAINT `FK_284_520` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`conda_commands` CHANGE `environment_file` `environment_yml` VARCHAR(1000) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`feature_store_jdbc_connector` DROP INDEX `jdbc_connector_feature_store_id_name`;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` DROP INDEX `s3_connector_feature_store_id_name`;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` DROP INDEX `fk_feature_store_s3_connector_1_idx`;

ALTER TABLE `hopsworks`.`feature_store_s3_connector` DROP COLUMN `iam_role`;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` DROP COLUMN `key_secret_uid`;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` DROP COLUMN `key_secret_name`;

DROP TABLE IF EXISTS `hopsworks`.`feature_store_redshift_connector`;

DROP TABLE IF EXISTS `hopsworks`.`cached_feature_extra_constraints`;
