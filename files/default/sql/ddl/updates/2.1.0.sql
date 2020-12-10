SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "conda_commands" AND REFERENCED_TABLE_NAME="project");
# If fk does not exist, then just execute "SELECT 1"
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
  `feature_store_id` int NOT NULL,
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
  `description` varchar(1000) DEFAULT NULL,
  `name` varchar(150) NOT NULL,
  `database_pwd_secret_uid` int DEFAULT NULL,
  `database_pwd_secret_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `redshift_connector_feature_store_id_name` (`name`,`feature_store_id`),
  KEY `fk_feature_store_redshift_connector_1_idx` (`feature_store_id`),
  KEY `fk_feature_store_redshift_connector_2_idx` (`database_pwd_secret_uid`,`database_pwd_secret_name`),
  CONSTRAINT `fk_feature_store_redshift_connector_1` FOREIGN KEY (`feature_store_id`) REFERENCES `feature_store` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_feature_store_redshift_connector_2` FOREIGN KEY (`database_pwd_secret_uid`, `database_pwd_secret_name`)
  REFERENCES `hopsworks`.`secrets` (`uid`, `secret_name`) ON DELETE RESTRICT
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

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
