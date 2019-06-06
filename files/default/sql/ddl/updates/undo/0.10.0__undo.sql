CREATE TABLE IF NOT EXISTS `jupyter_interpreter` (
  `port` int(11) NOT NULL,
  `name` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_accessed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`port`,`name`),
  CONSTRAINT `FK_523_530` FOREIGN KEY (`port`) REFERENCES `jupyter_project` (`port`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `jupyter_settings` ADD COLUMN `num_tf_ps` int(11) DEFAULT '1';
ALTER TABLE `jupyter_settings` ADD COLUMN `num_tf_gpus` int(11) DEFAULT '0';
ALTER TABLE `jupyter_settings` ADD COLUMN `num_mpi_np` int(11) DEFAULT '1';
ALTER TABLE `jupyter_settings` ADD COLUMN `appmaster_cores` int(11) DEFAULT '1';
ALTER TABLE `jupyter_settings` ADD COLUMN `appmaster_memory` int(11) DEFAULT '1024';
ALTER TABLE `jupyter_settings` ADD COLUMN `num_executors` int(11) DEFAULT '1';
ALTER TABLE `jupyter_settings` ADD COLUMN `num_executor_cores` int(11) DEFAULT '1';
ALTER TABLE `jupyter_settings` ADD COLUMN `executor_memory` int(11) DEFAULT '1024';
ALTER TABLE `jupyter_settings` ADD COLUMN `dynamic_initial_executors` int(11) DEFAULT '1';
ALTER TABLE `jupyter_settings` ADD COLUMN `dynamic_min_executors` int(11) DEFAULT '1';
ALTER TABLE `jupyter_settings` ADD COLUMN `dynamic_max_executors` int(11) DEFAULT '1';
ALTER TABLE `jupyter_settings` ADD COLUMN `mode` varchar(32) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `jupyter_settings` ADD COLUMN `archives` varchar(1500) COLLATE latin1_general_cs DEFAULT '';
ALTER TABLE `jupyter_settings` ADD COLUMN `jars` varchar(1500) COLLATE latin1_general_cs DEFAULT '';
ALTER TABLE `jupyter_settings` ADD COLUMN `files` varchar(1500) COLLATE latin1_general_cs DEFAULT '';
ALTER TABLE `jupyter_settings` ADD COLUMN `py_files` varchar(1500) COLLATE latin1_general_cs DEFAULT '';
ALTER TABLE `jupyter_settings` ADD COLUMN `spark_params` varchar(6500) COLLATE latin1_general_cs DEFAULT '';
ALTER TABLE `jupyter_settings` ADD COLUMN `fault_tolerant` tinyint(1) NOT NULL;
ALTER TABLE `jupyter_settings` ADD COLUMN `log_level` varchar(32) COLLATE latin1_general_cs DEFAULT 'INFO';
ALTER TABLE `jupyter_settings` ADD COLUMN `umask` varchar(32) COLLATE latin1_general_cs DEFAULT '022';
ALTER TABLE `jupyter_settings` DROP COLUMN `base_dir`;
ALTER TABLE `jupyter_settings` DROP COLUMN `json_config`;

DROP TABLE IF EXISTS `materialized_jwt`;

DROP TABLE IF EXISTS `oauth_client`;
DROP TABLE IF EXISTS `oauth_login_state`;

ALTER TABLE `remote_user` DROP COLUMN `id`;
ALTER TABLE `remote_user` DROP COLUMN `type`;
ALTER TABLE `remote_user` CHANGE COLUMN `uuid` `entry_uuid` varchar(128) NOT NULL;
ALTER TABLE `remote_user` ADD CONSTRAINT `entry_uuid_pk` PRIMARY KEY (`entry_uuid`);

ALTER TABLE `remote_user` RENAME TO `ldap_user`;

ALTER TABLE `tensorboard` DROP COLUMN `secret`;

CREATE TABLE `job_input_files` (
  `execution_id` int(11) NOT NULL,
  `path` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `name` varchar(255) COLLATE latin1_general_cs NOT NULL,
  PRIMARY KEY (`execution_id`,`name`),
  CONSTRAINT `FK_361_373` FOREIGN KEY (`execution_id`) REFERENCES `executions` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE `job_output_files` (
  `execution_id` int(11) NOT NULL,
  `path` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `name` varchar(255) COLLATE latin1_general_cs NOT NULL,
  PRIMARY KEY (`execution_id`,`name`),
  CONSTRAINT `FK_361_370` FOREIGN KEY (`execution_id`) REFERENCES `executions` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE `jobs_history` (
  `job_id` int(11) NOT NULL,
  `jar_file` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `execution_id` int(11) NOT NULL,
  `app_id` char(30) COLLATE latin1_general_cs DEFAULT NULL,
  `job_type` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `class_name` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `arguments` text COLLATE latin1_general_cs NOT NULL,
  `input_blocks_in_hdfs` int(11) NOT NULL,
  `am_memory` int(11) NOT NULL,
  `am_Vcores` int(11) NOT NULL,
  `execution_duration` bigint(20) DEFAULT NULL,
  `queuing_time` bigint(20) DEFAULT NULL,
  `user_email` varchar(150) COLLATE latin1_general_cs NOT NULL,
  `project_name` varchar(100) COLLATE latin1_general_cs NOT NULL,
  `job_name` varchar(128) COLLATE latin1_general_cs DEFAULT NULL,
  `state` varchar(128) COLLATE latin1_general_cs DEFAULT NULL,
  `final_status` varchar(128) COLLATE latin1_general_cs DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`execution_id`),
  UNIQUE KEY `inode_idx` (`app_id`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

DROP TABLE `hopsworks`.`maggy_driver`;

ALTER TABLE `jwt_signing_key` MODIFY COLUMN `name` VARCHAR(45) NOT NULL;

ALTER TABLE `hopsworks`.`serving` RENAME TO `hopsworks`.`tf_serving`;
ALTER TABLE `hopsworks`.`serving` DROP COLUMN `serving_type`;
ALTER TABLE `hopsworks`.`serving` CHANGE `name` `model_name` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`serving` CHANGE `artifact_path` `model_path` varchar(255) COLLATE latin1_general_cs NOT NULL;

ALTER TABLE `hopsworks`.`jupyter_project` ADD COLUMN `host_ip` varchar(255) COLLATE latin1_general_cs NOT NULL;