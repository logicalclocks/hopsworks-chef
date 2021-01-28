SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "conda_commands" AND REFERENCED_TABLE_NAME="project"); # If fk does not exist, then just execute "SELECT 1"
SET @s = (SELECT IF((@fk_name) is not null,
                    concat('ALTER TABLE hopsworks.conda_commands DROP FOREIGN KEY `', @fk_name, '`'),
                    "SELECT 1"));
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

ALTER TABLE `hopsworks`.`conda_commands` CHANGE `environment_yml` `environment_file` VARCHAR(1000) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`feature_store_jdbc_connector` ADD UNIQUE INDEX `jdbc_connector_feature_store_id_name` (`feature_store_id`, `name`);

ALTER TABLE `hopsworks`.`feature_store_s3_connector` ADD UNIQUE INDEX `s3_connector_feature_store_id_name` (`feature_store_id`, `name`);
ALTER TABLE `hopsworks`.`feature_store_s3_connector` ADD COLUMN `iam_role` VARCHAR(2048) DEFAULT NULL;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` ADD COLUMN `key_secret_uid` INT DEFAULT NULL;
ALTER TABLE `hopsworks`.`feature_store_s3_connector` ADD COLUMN `key_secret_name` VARCHAR(200) DEFAULT NULL;

ALTER TABLE `hopsworks`.`feature_store_s3_connector`
ADD INDEX `fk_feature_store_s3_connector_1_idx` (`key_secret_uid`, `key_secret_name`);
ALTER TABLE `hopsworks`.`feature_store_s3_connector` ADD CONSTRAINT `fk_feature_store_s3_connector_1`
  FOREIGN KEY (`key_secret_uid` , `key_secret_name`)
  REFERENCES `hopsworks`.`secrets` (`uid` , `secret_name`)
  ON DELETE RESTRICT;

CREATE TABLE `feature_store_redshift_connector` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cluster_identifier` varchar(64) NOT NULL,
  `database_driver` varchar(64) NOT NULL,
  `database_endpoint` varchar(128) DEFAULT NULL,
  `database_name` varchar(64) DEFAULT NULL,
  `database_port` int DEFAULT NULL,
  `table_name` varchar(128) DEFAULT NULL,
  `database_user_name` varchar(128) DEFAULT NULL,
  `auto_create` tinyint(1) DEFAULT 0,
  `database_group` varchar(2048) DEFAULT NULL,
  `iam_role` varchar(2048) DEFAULT NULL,
  `arguments` varchar(2000) DEFAULT NULL,
  `database_pwd_secret_uid` int DEFAULT NULL,
  `database_pwd_secret_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_feature_store_redshift_connector_2_idx` (`database_pwd_secret_uid`,`database_pwd_secret_name`),
  CONSTRAINT `fk_feature_store_redshift_connector_2` FOREIGN KEY (`database_pwd_secret_uid`, `database_pwd_secret_name`)
  REFERENCES `hopsworks`.`secrets` (`uid`, `secret_name`) ON DELETE RESTRICT
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_store_adls_connector` (
  `id`                    INT(11)       NOT NULL AUTO_INCREMENT,
  `generation`            INT(11)       NOT NULL,
  `directory_id`          VARCHAR(40)   NOT NULL,
  `application_id`        VARCHAR(40)   NOT NULL,
  `account_name`          VARCHAR(30)   NOT NULL,
  `container_name`        VARCHAR(65),
  `cred_secret_uid`       INT           NOT NULL,
  `cred_secret_name`      VARCHAR(200)  NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `adls_cred_secret_fk` FOREIGN KEY (`cred_secret_uid` , `cred_secret_name`)
  REFERENCES `hopsworks`.`secrets` (`uid` , `secret_name`) ON DELETE RESTRICT
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_store_connector` (
  `id`                      INT(11)          NOT NULL AUTO_INCREMENT,
  `feature_store_id`        INT(11)          NOT NULL,
  `name`                    VARCHAR(150)     NOT NULL,
  `description`             VARCHAR(1000)    NULL,
  `type`                    INT(11)          NOT NULL,
  `jdbc_id`                 INT(11),
  `s3_id`                   INT(11),
  `hopsfs_id`               INT(11),
  `redshift_id`             INT(11),
  `adls_id`                 INT(11),
  PRIMARY KEY (`id`),
  UNIQUE KEY `fs_conn_name` (`name`, `feature_store_id`),
  CONSTRAINT `fs_connector_featurestore_fk` FOREIGN KEY (`feature_store_id`) REFERENCES `hopsworks`.`feature_store` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fs_connector_jdbc_fk` FOREIGN KEY (`jdbc_id`) REFERENCES `hopsworks`.`feature_store_jdbc_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fs_connector_s3_fk` FOREIGN KEY (`s3_id`) REFERENCES `hopsworks`.`feature_store_s3_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fs_connector_hopsfs_fk` FOREIGN KEY (`hopsfs_id`) REFERENCES `hopsworks`.`feature_store_hopsfs_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fs_connector_redshift_fk` FOREIGN KEY (`redshift_id`) REFERENCES `hopsworks`.`feature_store_redshift_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fs_connector_adls_fk` FOREIGN KEY (`adls_id`) REFERENCES `hopsworks`.`feature_store_adls_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

INSERT INTO `feature_store_connector`(`feature_store_id`, `name`, `description`, `type`, `jdbc_id`)
SELECT `feature_store_id`, `name`, `description`, 0, `id` FROM `feature_store_jdbc_connector`;
ALTER TABLE `feature_store_jdbc_connector`
    DROP FOREIGN KEY `jdbc_connector_featurestore_fk`,
    DROP COLUMN `feature_store_id`,
    DROP COLUMN `name`,
    DROP COLUMN `description`;

INSERT INTO `feature_store_connector`(`feature_store_id`, `name`, `description`, `type`, `hopsfs_id`)
SELECT `feature_store_id`, `name`, `description`, 1, `id` FROM `feature_store_hopsfs_connector`;
ALTER TABLE `feature_store_hopsfs_connector`
    DROP FOREIGN KEY `hopsfs_connector_featurestore_fk`,
    DROP COLUMN `feature_store_id`,
    DROP COLUMN `name`,
    DROP COLUMN `description`;

INSERT INTO `feature_store_connector`(`feature_store_id`, `name`, `description`, `type`, `s3_id`)
SELECT `feature_store_id`, `name`, `description`, 2, `id` FROM `feature_store_s3_connector`;
ALTER TABLE `feature_store_s3_connector`
    DROP FOREIGN KEY `s3_connector_featurestore_fk`,
    DROP COLUMN `feature_store_id`,
    DROP COLUMN `name`,
    DROP COLUMN `description`;

ALTER TABLE `on_demand_feature_group` ADD COLUMN `connector_id` int(11), 
    ADD COLUMN `data_format` INT(11),
    ADD COLUMN `path` VARCHAR(1000),
    MODIFY `query` VARCHAR(11000),
    ADD CONSTRAINT `on_demand_conn_fk` FOREIGN KEY (`connector_id`) 
    REFERENCES `hopsworks`.`feature_store_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

SET SQL_SAFE_UPDATES = 0;
UPDATE `on_demand_feature_group` `fg` 
SET `fg`.`connector_id` = (SELECT `id` FROM `feature_store_connector` `fc` 
WHERE `fc`.`jdbc_id` = `fg`.`jdbc_connector_id`);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `on_demand_feature_group` DROP FOREIGN KEY `on_demand_fg_jdbc_fk`,
    DROP COLUMN `jdbc_connector_id`;

ALTER TABLE `external_training_dataset` ADD COLUMN `connector_id` int(11), 
    ADD CONSTRAINT `ext_td_conn_fk` FOREIGN KEY (`connector_id`) 
    REFERENCES `hopsworks`.`feature_store_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

SET SQL_SAFE_UPDATES = 0;
UPDATE `external_training_dataset` `fg` 
SET `fg`.`connector_id` = (SELECT `id` FROM `feature_store_connector` `fc` 
WHERE `fc`.`s3_id` = `fg`.`s3_connector_id`);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `external_training_dataset` DROP FOREIGN KEY `external_td_s3_connector_fk`,
    DROP COLUMN `s3_connector_id`;

ALTER TABLE `hopsfs_training_dataset` ADD COLUMN `connector_id` int(11), 
    ADD CONSTRAINT `hopsfs_td_conn_fk` FOREIGN KEY (`connector_id`) 
    REFERENCES `hopsworks`.`feature_store_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsfs_training_dataset` `fg` 
SET `fg`.`connector_id` = (SELECT `id` FROM `feature_store_connector` `fc` 
WHERE `fc`.`hopsfs_id` = `fg`.`hopsfs_connector_id`);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsfs_training_dataset` DROP FOREIGN KEY `hopsfs_td_connector_fk`,
    DROP COLUMN `hopsfs_connector_id`;

CREATE TABLE `cached_feature_extra_constraints` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cached_feature_group_id` int(11) NULL,
  `name` varchar(63) COLLATE latin1_general_cs NOT NULL,
  `primary_column` tinyint(1) NOT NULL DEFAULT '0',
  `hudi_precombine_key` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `cached_feature_group_fk` (`cached_feature_group_id`),
  CONSTRAINT `cached_feature_group_fk1` FOREIGN KEY (`cached_feature_group_id`) REFERENCES `cached_feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE `on_demand_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `on_demand_feature_group_id` int(11) NULL,
  `name` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `value` varchar(255) COLLATE latin1_general_cs NOT NULL,
  PRIMARY KEY (`id`),
  KEY `on_demand_option_key` (`on_demand_feature_group_id`),
  CONSTRAINT `on_demand_option_fk` FOREIGN KEY (`on_demand_feature_group_id`) REFERENCES `on_demand_feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`project` ADD COLUMN `python_env_id` int(11) DEFAULT NULL;

CREATE TABLE IF NOT EXISTS `python_environment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `python_version` VARCHAR(25) COLLATE latin1_general_cs NOT NULL,
  `jupyter_conflicts` TINYINT(1) NOT NULL DEFAULT '0',
  `conflicts` VARCHAR(12000) COLLATE latin1_general_cs DEFAULT NULL,
  UNIQUE KEY `project_env` (`project_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `FK_PYTHONENV_PROJECT` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

INSERT INTO `hopsworks`.`python_environment` (`project_id`, `python_version`)
SELECT `id`, `python_version`
FROM `hopsworks`.`project`
WHERE `python_version` IS NOT NULL
AND `conda` = true;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`project`
SET `project`.`python_env_id` = (SELECT `id` FROM `python_environment`
WHERE `python_environment`.`project_id` = `project`.`id`);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`project` DROP COLUMN `conda`;

ALTER TABLE `hopsworks`.`project` DROP COLUMN `python_version`;

CREATE TABLE `statistics_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `feature_group_id` int(11),
  `training_dataset_id` int(11),
  `descriptive` TINYINT(1) NOT NULL DEFAULT '1',
  `correlations` TINYINT(1) NOT NULL DEFAULT '0',
  `histograms` TINYINT(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `feature_group_id` (`feature_group_id`),
  KEY `training_dataset_id` (`training_dataset_id`),
  CONSTRAINT `fg_statistics_config_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `td_statistics_config_fk` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

INSERT INTO `hopsworks`.`statistics_config` (`feature_group_id`, `descriptive`, `correlations`, `histograms`)
SELECT `id` as `feature_group_id`,
       `desc_stats_enabled` as `descriptive`,
       `feat_corr_enabled` as `correlations`,
       `feat_hist_enabled` as `histograms`
    FROM `hopsworks`.`feature_group`;

ALTER TABLE `hopsworks`.`feature_group`
    DROP COLUMN `desc_stats_enabled`,
    DROP COLUMN `feat_corr_enabled`,
    DROP COLUMN `feat_hist_enabled`;

drop procedure if exists schema_change;
delimiter ;;
create procedure schema_change() begin

 /* delete columns if they exist */
 if exists (select * from information_schema.columns where table_name = 'feature_group' and column_name = 'cluster_analysis_enabled') then
  alter table `hopsworks`.`feature_group` drop column `cluster_analysis_enabled`;
 end if;
 if exists (select * from information_schema.columns where table_name = 'feature_group' and column_name = 'num_clusters') then
  alter table `hopsworks`.`feature_group` drop column `num_clusters`;
 end if;
 if exists (select * from information_schema.columns where table_name = 'feature_group' and column_name = 'num_bins') then
  alter table `hopsworks`.`feature_group` drop column `num_bins`;
 end if;
 if exists (select * from information_schema.columns where table_name = 'feature_group' and column_name = 'corr_method') then
  alter table `hopsworks`.`feature_group` drop column `corr_method`;
 end if;

end ;;

call schema_change();;

delimiter ;
drop procedure if exists schema_change;

INSERT INTO `hopsworks`.`statistics_config` (`training_dataset_id`, `descriptive`, `correlations`, `histograms`)
SELECT `id` as `training_dataset_id`,
       1 as `descriptive`,
       0 as `correlations`,
       0 as `histograms`
    FROM `hopsworks`.`training_dataset`;

ALTER TABLE `hopsworks`.`statistic_columns`
  DROP KEY `feature_group_id`,
  DROP FOREIGN KEY `statistic_column_fk`,
  ADD COLUMN `statistics_config_id` int(11) after `id`,
  ADD KEY `statistics_config_id` (`statistics_config_id`),
  ADD CONSTRAINT `statistics_config_fk` FOREIGN KEY (`statistics_config_id`) REFERENCES `statistics_config` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`statistics_config` `sc` INNER JOIN `hopsworks`.`statistic_columns` `col` ON `sc`.`feature_group_id` = `col`.`feature_group_id`
SET `col`.`statistics_config_id` =  `sc`.`id`;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`statistic_columns` DROP COLUMN `feature_group_id`;
ALTER TABLE `hopsworks`.`oauth_login_state` CHANGE COLUMN `token` `token` VARCHAR(8000) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`oauth_client`
ADD COLUMN `offline_access` tinyint(1) NOT NULL DEFAULT '0',
ADD COLUMN `code_challenge` tinyint(1) NOT NULL DEFAULT '0',
ADD COLUMN `code_challenge_method` varchar(16) DEFAULT NULL,
ADD COLUMN `verify_email` tinyint(1) NOT NULL DEFAULT '0';

ALTER TABLE `hopsworks`.`oauth_login_state`
ADD COLUMN `code_challenge` varchar(128) DEFAULT NULL,
ADD COLUMN `session_id` VARCHAR(128) NOT NULL,
ADD COLUMN `redirect_uri` VARCHAR(1024) NOT NULL,
ADD COLUMN `scopes` VARCHAR(2048) NOT NULL;

ALTER TABLE `hopsworks`.`feature_store_statistic` MODIFY `commit_time` DATETIME(3)  NOT NULL,
    ADD COLUMN `feature_group_commit_id` BIGINT(20),
    ADD CONSTRAINT `fg_ci_fk_fss` FOREIGN KEY (`feature_group_id`, `feature_group_commit_id`) REFERENCES `feature_group_commit` (`feature_group_id`, `commit_id`) ON DELETE CASCADE ON UPDATE NO ACTION;
