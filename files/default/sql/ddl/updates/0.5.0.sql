CREATE TABLE IF NOT EXISTS `system_commands` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `host_id` int(11) NOT NULL,
  `op` varchar(50) NOT NULL,
  `arguments` varchar(255) DEFAULT NULL,
  `status` varchar(20) NOT NULL,
  `priority` int(11) NOT NULL DEFAULT '0',
  `exec_user` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `host_id` (`host_id`),
  FOREIGN KEY (`host_id`) REFERENCES `hosts` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `pia` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `project_id` INT(11) DEFAULT NULL,
  `personal_data` VARCHAR(4000) NOT NULL,
  `how_data_collected` VARCHAR(2000) NOT NULL,
  `specified_explicit_legitimate` int(11) NOT NULL DEFAULT '0',
  `consent_process` varchar(1000) DEFAULT NULL,
  `consent_basis` varchar(1000) DEFAULT NULL,
  `data_minimized` int(11) NOT NULL DEFAULT '0',
  `data_uptodate` int(11) NOT NULL DEFAULT '0',
  `users_informed_how` varchar(500) NOT NULL,
  `user_controls_data_collection_retention` varchar(500) NOT NULL,
  `data_encrypted` int(11) NOT NULL DEFAULT '0',
  `data_anonymized` int(11) NOT NULL DEFAULT '0',
  `data_pseudonymized` int(11) NOT NULL DEFAULT '0',
  `data_backedup` int(11) NOT NULL DEFAULT '0',
  `data_security_measures` varchar(500) NOT NULL,
  `data_portability_measure` varchar(500) NOT NULL,
  `subject_access_rights` varchar(500) NOT NULL,
  `risks` varchar(2000) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


ALTER TABLE `hopsworks`.`jupyter_settings` ADD COLUMN `shutdown_level` INT NOT NULL DEFAULT 6;

--
-- RStudio support
--

CREATE TABLE IF NOT EXISTS `rstudio_settings` (
  `project_id` INT(11) NOT NULL,
  `team_member` VARCHAR(150) NOT NULL,
  `num_tf_ps` INT(11) DEFAULT '1',
  `num_tf_gpus` INT(11) DEFAULT '0',
  `num_mpi_np` INT(11) DEFAULT '1',
  `appmaster_cores` INT(11) DEFAULT '1',
  `appmaster_memory` INT(11) DEFAULT '1024',
  `num_executors` INT(11) DEFAULT '1',
  `num_executor_cores` INT(11) DEFAULT '1',
  `executor_memory` INT(11) DEFAULT '1024',
  `dynamic_initial_executors` INT(11) DEFAULT '1',
  `dynamic_min_executors` INT(11) DEFAULT '1',
  `dynamic_max_executors` INT(11) DEFAULT '1',
  `secret` VARCHAR(255) NOT NULL,
  `log_level` VARCHAR(32) NULL DEFAULT 'INFO',
  `mode` VARCHAR(32) NOT NULL,
  `umask` VARCHAR(32) DEFAULT '022',
  `advanced` tinyint(1) DEFAULT '0',
  `archives` VARCHAR(1500) DEFAULT '',
  `jars` VARCHAR(1500) DEFAULT '',
  `files` VARCHAR(1500) DEFAULT '',
  `py_files` VARCHAR(1500) DEFAULT '',
  `spark_params` VARCHAR(6500) DEFAULT '',
  `shutdown_level` INT NOT NULL DEFAULT 6,
  PRIMARY KEY (`project_id`,`team_member`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`team_member`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE NO ACTION,
  KEY secret_idx(`secret`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `rstudio_project` (
  `port` INT(11) NOT NULL,
  `hdfs_user_id` int(11) NOT NULL,
  `created` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `last_accessed` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `host_ip` VARCHAR(255) NOT NULL,
  `token` VARCHAR(255) NOT NULL,
  `secret` VARCHAR(64) NOT NULL,
  `pid` BIGINT NOT NULL,
  `project_id` INT(11) NOT NULL,
  PRIMARY KEY (`port`),
  KEY `hdfs_user_idx` (`hdfs_user_id`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
  ) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

--
-- Mapping of rstudio servers to Livy interpreters
--
CREATE TABLE IF NOT EXISTS `rstudio_interpreter` (
  `port` INT(11) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `created` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `last_accessed` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`port`,`name`),
  FOREIGN KEY (`port`) REFERENCES `rstudio_project` (`port`) ON DELETE CASCADE ON UPDATE NO ACTION
  ) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


--
--  tensorflow_graph optimization
--
ALTER TABLE `hopsworks`.`tf_serving` ADD COLUMN `optimized` TINYINT NOT NULL DEFAULT 0;
ALTER TABLE `hopsworks`.`project` ADD COLUMN `kafka_max_num_topics` INT NOT NULL DEFAULT 100;

ALTER TABLE `hopsworks`.`hosts` CHANGE COLUMN `has_gpus` `num_gpus` TINYINT(1) NOT NULL DEFAULT 0;
ALTER TABLE `hopsworks`.`hosts` ADD COLUMN `conda_enabled` TINYINT(1) NOT NULL DEFAULT 1;

--
-- Exporting Anaconda environment as yml
--
ALTER TABLE `hopsworks`.`conda_commands` ADD COLUMN `environment_yml` VARCHAR(10000) DEFAULT NULL;

ALTER TABLE `hopsworks`.`jupyter_settings` ADD COLUMN `fault_tolerant` TINYINT(1) NOT NULL;
