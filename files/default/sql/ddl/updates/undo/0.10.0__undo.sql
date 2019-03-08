ALTER TABLE jupyter_project CHANGE `expires` `last_accessed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

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