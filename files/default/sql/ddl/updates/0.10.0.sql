DROP TABLE IF EXISTS  `hopsworks`.`projectgenericuser_certs`;
DROP TABLE IF EXISTS  `hopsworks`.`zeppelin_interpreter_confs`;

-- Remove Zeppelin as service from existing projects
DELETE FROM `hopsworks`.`project_services` where `service`='ZEPPELIN';

DROP TABLE IF EXISTS `jupyter_interpreter`;

ALTER TABLE `jupyter_settings` DROP COLUMN `num_tf_ps`;
ALTER TABLE `jupyter_settings` DROP COLUMN `num_tf_gpus`;
ALTER TABLE `jupyter_settings` DROP COLUMN `num_mpi_np`;
ALTER TABLE `jupyter_settings` DROP COLUMN `appmaster_cores`;
ALTER TABLE `jupyter_settings` DROP COLUMN `appmaster_memory`;
ALTER TABLE `jupyter_settings` DROP COLUMN `num_executors`;
ALTER TABLE `jupyter_settings` DROP COLUMN `num_executor_cores`;
ALTER TABLE `jupyter_settings` DROP COLUMN `executor_memory`;
ALTER TABLE `jupyter_settings` DROP COLUMN `dynamic_initial_executors`;
ALTER TABLE `jupyter_settings` DROP COLUMN `dynamic_min_executors`;
ALTER TABLE `jupyter_settings` DROP COLUMN `dynamic_max_executors`;
ALTER TABLE `jupyter_settings` DROP COLUMN `mode`;
ALTER TABLE `jupyter_settings` DROP COLUMN `archives`;
ALTER TABLE `jupyter_settings` DROP COLUMN `jars`;
ALTER TABLE `jupyter_settings` DROP COLUMN `files`;
ALTER TABLE `jupyter_settings` DROP COLUMN `py_files`;
ALTER TABLE `jupyter_settings` DROP COLUMN `spark_params`;
ALTER TABLE `jupyter_settings` DROP COLUMN `fault_tolerant`;
ALTER TABLE `jupyter_settings` DROP COLUMN `umask`;
ALTER TABLE `jupyter_settings` DROP COLUMN `log_level`;
ALTER TABLE `jupyter_settings` ADD COLUMN `base_dir` VARCHAR(255) DEFAULT '/Jupyter/';
ALTER TABLE `jupyter_settings` ADD COLUMN `json_config` TEXT NOT NULL;

CREATE TABLE IF NOT EXISTS `materialized_jwt` (
  `project_id` INT(11) NOT NULL,
  `user_id`    INT(11) NOT NULL,
  `usage`      TINYINT(4) NOT NULL,
  PRIMARY KEY (`project_id`, `user_id`, `usage`),
  FOREIGN KEY `jwt_material_project` (`project_id`) REFERENCES `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY `jwt_material_user` (`user_id`) REFERENCES `users` (`uid`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `ldap_user` REMOVE PARTITIONING;
ALTER TABLE `ldap_user` DROP PRIMARY KEY;
ALTER TABLE `ldap_user` ADD COLUMN `id` INT(11) AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE `ldap_user` RENAME TO `remote_user`;
ALTER TABLE `remote_user` CHANGE COLUMN `entry_uuid` `uuid` varchar(128) NOT NULL;
ALTER TABLE `remote_user` ADD CONSTRAINT `uuid_UNIQUE` UNIQUE (`uuid`);
ALTER TABLE `remote_user` ADD COLUMN `type` varchar(45) NOT NULL;

CREATE TABLE IF NOT EXISTS `oauth_client` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_id` varchar(256) NOT NULL,
  `client_secret` varchar(2048) NOT NULL,
  `provider_logo_uri` varchar(2048) DEFAULT NULL,
  `provider_uri` varchar(2048) NOT NULL,
  `provider_name` varchar(256) NOT NULL,
  `provider_display_name` varchar(45) NOT NULL,
  `authorisation_endpoint` varchar(1024) DEFAULT NULL,
  `token_endpoint` varchar(1024) DEFAULT NULL,
  `userinfo_endpoint` varchar(1024) DEFAULT NULL,
  `jwks_uri` varchar(1024) DEFAULT NULL,
  `provider_metadata_endpoint_supported` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `client_id_UNIQUE` (`client_id`),
  UNIQUE KEY `provider_name_UNIQUE` (`provider_name`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `oauth_login_state` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(128) NOT NULL,
  `client_id` varchar(256) NOT NULL,
  `login_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `token` varchar(2048) DEFAULT NULL,
  `nonce` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `state_UNIQUE` (`state`),
  FOREIGN KEY `fk_oauth_login_state_client` (`client_id`) REFERENCES `oauth_client` (`client_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `tensorboard` ADD COLUMN `secret` VARCHAR(255);


--
--  Maggy Driver Service Lookup Table in Hopsworks
--
CREATE TABLE IF NOT EXISTS `maggy_driver` (
  `id` MEDIUMINT NOT NULL AUTO_INCREMENT,
  `app_id` char(30) COLLATE latin1_general_cs NOT NULL,
  `host_ip` varchar(128) COLLATE latin1_general_cs NOT NULL,
  `port` int(11) NOT NULL,
  `secret` varchar(128) COLLATE latin1_general_cs NOT NULL,
  `created`    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY (`app_id`, `port`),
  PRIMARY KEY (`id`)
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

DROP TABLE IF EXISTS `hopsworks`.`jobs_history`;
DROP TABLE IF EXISTS `hopsworks`.`job_input_files`;
DROP TABLE IF EXISTS `hopsworks`.`job_output_files`;

ALTER TABLE `jwt_signing_key` MODIFY COLUMN `name` VARCHAR(255) NOT NULL;

ALTER TABLE `hopsworks`.`tf_serving` RENAME TO `hopsworks`.`serving`;
ALTER TABLE `hopsworks`.`serving` ADD COLUMN `serving_type` INT(11) NOT NULL DEFAULT '0';
ALTER TABLE `hopsworks`.`serving` CHANGE `model_name` `name` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`serving` CHANGE `model_path` `artifact_path` varchar(255) COLLATE latin1_general_cs NOT NULL;

ALTER TABLE `hopsworks`.`jupyter_project` DROP COLUMN `host_ip`;