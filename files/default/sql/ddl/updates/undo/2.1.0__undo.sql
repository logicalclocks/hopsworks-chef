ALTER TABLE `hopsworks`.`conda_commands` ADD CONSTRAINT `FK_284_520` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`conda_commands` CHANGE `environment_file` `environment_yml` VARCHAR(1000) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`feature_store_jdbc_connector` DROP INDEX `jdbc_connector_feature_store_id_name`;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` DROP INDEX `s3_connector_feature_store_id_name`;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` DROP INDEX `fk_feature_store_s3_connector_1_idx`;

ALTER TABLE `hopsworks`.`feature_store_s3_connector` DROP COLUMN `iam_role`;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` DROP COLUMN `key_secret_uid`;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` DROP COLUMN `key_secret_name`;

DROP TABLE IF EXISTS `hopsworks`.`feature_store_redshift_connector`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_adls_connector`;

DROP TABLE IF EXISTS `hopsworks`.`cached_feature_extra_constraints`;

ALTER TABLE `feature_store_s3_connector`
    ADD COLUMN `feature_store_id` INT(11),
    ADD COLUMN `name` VARCHAR(150),
    ADD COLUMN `description` VARCHAR(1000),
    ADD CONSTRAINT `s3_connector_featurestore_fk` FOREIGN KEY (`feature_store_id`) REFERENCES `hopsworks`.`feature_store` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

SET SQL_SAFE_UPDATES = 0;
UPDATE `feature_store_s3_connector` `s3_conn` 
SET `s3_conn`.`name` = (SELECT `fc`.`name` FROM `feature_store_connector` `fc` 
WHERE `s3_conn`.`id` = `fc`.`s3_id`);
UPDATE `feature_store_s3_connector` `s3_conn` 
SET `s3_conn`.`description` = (SELECT `fc`.`description` FROM `feature_store_connector` `fc` 
WHERE `s3_conn`.`id` = `fc`.`s3_id`);
UPDATE `feature_store_s3_connector` `s3_conn` 
SET `s3_conn`.`feature_store_id` = (SELECT `fc`.`feature_store_id` FROM `feature_store_connector` `fc` 
WHERE `s3_conn`.`id` = `fc`.`s3_id`);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `feature_store_jdbc_connector`
    ADD COLUMN `feature_store_id` INT(11),
    ADD COLUMN `name` VARCHAR(150),
    ADD COLUMN `description` VARCHAR(1000),
    ADD CONSTRAINT `jdbc_connector_featurestore_fk` FOREIGN KEY (`feature_store_id`) REFERENCES `hopsworks`.`feature_store` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

SET SQL_SAFE_UPDATES = 0;
UPDATE `feature_store_jdbc_connector` `jdbc_conn` 
SET `jdbc_conn`.`name` = (SELECT `fc`.`name` FROM `feature_store_connector` `fc` 
WHERE `jdbc_conn`.`id` = `fc`.`jdbc_id`);
UPDATE `feature_store_jdbc_connector` `jdbc_conn` 
SET `jdbc_conn`.`description` = (SELECT `fc`.`description` FROM `feature_store_connector` `fc` 
WHERE `jdbc_conn`.`id` = `fc`.`jdbc_id`);
UPDATE `feature_store_jdbc_connector` `jdbc_conn` 
SET `jdbc_conn`.`feature_store_id` = (SELECT `fc`.`feature_store_id` FROM `feature_store_connector` `fc` 
WHERE `jdbc_conn`.`id` = `fc`.`jdbc_id`);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `feature_store_hopsfs_connector`
    ADD COLUMN `feature_store_id` INT(11),
    ADD COLUMN `name` VARCHAR(150),
    ADD COLUMN `description` VARCHAR(1000),
    ADD CONSTRAINT `hopsfs_connector_featurestore_fk` FOREIGN KEY (`feature_store_id`) REFERENCES `hopsworks`.`feature_store` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

SET SQL_SAFE_UPDATES = 0;
UPDATE `feature_store_hopsfs_connector` `hopsfs_conn` 
SET `hopsfs_conn`.`name` = (SELECT `fc`.`name` FROM `feature_store_connector` `fc` 
WHERE `hopsfs_conn`.`id` = `fc`.`hopsfs_id`);
UPDATE `feature_store_hopsfs_connector` `hopsfs_conn` 
SET `hopsfs_conn`.`description` = (SELECT `fc`.`description` FROM `feature_store_connector` `fc` 
WHERE `hopsfs_conn`.`id` = `fc`.`hopsfs_id`);
UPDATE `feature_store_hopsfs_connector` `hopsfs_conn` 
SET `hopsfs_conn`.`feature_store_id` = (SELECT `fc`.`feature_store_id` FROM `feature_store_connector` `fc` 
WHERE `hopsfs_conn`.`id` = `fc`.`hopsfs_id`);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `on_demand_feature_group` ADD COLUMN `jdbc_connector_id` int(11), 
    ADD CONSTRAINT `on_demand_fg_jdbc_fk` FOREIGN KEY (`jdbc_connector_id`) 
    REFERENCES `hopsworks`.`feature_store_jdbc_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

SET SQL_SAFE_UPDATES = 0;
UPDATE `on_demand_feature_group` `fg` 
SET `fg`.`jdbc_connector_id` = (SELECT `fc`.`jdbc_id` FROM `feature_store_connector` `fc` 
WHERE `fc`.`id` = `fg`.`connector_id`);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `on_demand_feature_group` DROP FOREIGN KEY `on_demand_conn_fk`,
    DROP COLUMN `connector_id`;

ALTER TABLE `external_training_dataset` ADD COLUMN `s3_connector_id` int(11),
    ADD CONSTRAINT `external_td_s3_connector_fk` FOREIGN KEY (`s3_connector_id`) 
    REFERENCES `hopsworks`.`feature_store_s3_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

SET SQL_SAFE_UPDATES = 0;
UPDATE `external_training_dataset` `fg` 
SET `fg`.`s3_connector_id` = (SELECT `fc`.`s3_id` FROM `feature_store_connector` `fc` 
WHERE `fc`.`id` = `fg`.`connector_id`);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `external_training_dataset` DROP FOREIGN KEY `ext_td_conn_fk`,
    DROP COLUMN `connector_id`;

ALTER TABLE `hopsfs_training_dataset` ADD COLUMN `hopsfs_connector_id` int(11),
    ADD CONSTRAINT `hopsfs_td_connector_fk` FOREIGN KEY (`hopsfs_connector_id`) 
    REFERENCES `hopsworks`.`feature_store_hopsfs_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

SET SQL_SAFE_UPDATES = 0;
UPDATE `external_training_dataset` `fg` 
SET `fg`.`hopsfs_connector_id` = (SELECT `fc`.`hopsfs_id` FROM `feature_store_connector` `fc` 
WHERE `fc`.`id` = `fg`.`connector_id`);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsfs_training_dataset` DROP FOREIGN KEY `hopsfs_td_conn_fk`,
    DROP COLUMN `connector_id`;

ALTER TABLE `on_demand_feature_group` 
    DROP COLUMN `data_format`,
    DROP COLUMN `path`,
    MODIFY `query` VARCHAR(11000) NOT NULL;

DROP TABLE `feature_store_connector`;
DROP TABLE `on_demand_option`;

ALTER TABLE `hopsworks`.`project` ADD COLUMN `conda` tinyint(1) DEFAULT '0';
ALTER TABLE `hopsworks`.`project` ADD COLUMN `python_version` varchar(25) COLLATE latin1_general_cs DEFAULT NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`project`
SET `hopsworks`.`project`.`python_version` = (SELECT `python_version`
                                  FROM `hopsworks`.`python_environment`
                                  WHERE `hopsworks`.`project`.`id` = `python_environment`.`project_id`),
`project`.`conda` = (CASE WHEN EXISTS (SELECT 1
                                      FROM `hopsworks`.`python_environment`
                                      WHERE `hopsworks`.`project`.`id` = `python_environment`.`project_id`)
                                      THEN 1 ELSE 0 END);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`python_environment` DROP FOREIGN KEY `FK_PYTHONENV_PROJECT`;

ALTER TABLE `hopsworks`.`project` DROP COLUMN `python_env_id`;

DROP TABLE IF EXISTS `hopsworks`.`python_environment`;

ALTER TABLE `hopsworks`.`feature_group`
    ADD COLUMN `desc_stats_enabled` TINYINT(1) NOT NULL DEFAULT '1',
    ADD COLUMN `feat_corr_enabled` TINYINT(1) NOT NULL DEFAULT '1',
    ADD COLUMN `feat_hist_enabled` TINYINT(1) NOT NULL DEFAULT '1';

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`feature_group` `fg` INNER JOIN `hopsworks`.`statistics_config` `sc` ON `fg`.`id` = `sc`.`feature_group_id`
SET `fg`.`desc_stats_enabled` =  `sc`.`descriptive`,
    `fg`.`feat_corr_enabled` = `sc`.`correlations`,
    `fg`.`feat_hist_enabled` = `sc`.`histograms`;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`statistic_columns`
  DROP KEY `statistics_config_id`,
  DROP FOREIGN KEY `statistics_config_fk`,
  ADD COLUMN `feature_group_id` int(11) after `id`,
  ADD KEY `feature_group_id` (`feature_group_id`),
  ADD CONSTRAINT `statistic_column_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`statistics_config` `sc` INNER JOIN `hopsworks`.`statistic_columns` `col` ON `sc`.`id` = `col`.`statistics_config_id`
SET `col`.`feature_group_id` =  `sc`.`feature_group_id`;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`statistic_columns` DROP COLUMN `statistics_config_id`;

DROP TABLE `hopsworks`.`statistics_config`;

ALTER TABLE `hopsworks`.`oauth_login_state` CHANGE COLUMN `token` `token` VARCHAR(2048) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`oauth_client` 
DROP COLUMN `offline_access`,
DROP COLUMN `code_challenge`,
DROP COLUMN `code_challenge_method`,
DROP COLUMN `verify_email`;

ALTER TABLE `hopsworks`.`oauth_login_state` 
DROP COLUMN `code_challenge`,
DROP COLUMN `session_id`,
DROP COLUMN `redirect_uri`,
DROP COLUMN `scopes`;

