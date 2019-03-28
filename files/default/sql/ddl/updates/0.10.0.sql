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

CREATE TABLE IF NOT EXISTS `airflow_material` (
  `project_id` INT(11) NOT NULL,
  `user_id`    INT(11) NOT NULL,
  PRIMARY KEY (`project_id`, `user_id`),
  FOREIGN KEY `airflow_material_project` (`project_id`) REFERENCES `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY `airflow_material_user` (`user_id`) REFERENCES `users` (`uid`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
