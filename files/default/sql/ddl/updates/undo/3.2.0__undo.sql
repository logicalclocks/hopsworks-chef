ALTER TABLE `hopsworks`.`project` ADD COLUMN `retention_period` date DEFAULT NULL,
  ADD COLUMN `archived` tinyint(1) DEFAULT '0',
  ADD COLUMN `logs` tinyint(1) DEFAULT '0',
  ADD COLUMN `deleted` tinyint(1) DEFAULT '0';

DROP TABLE IF EXISTS `hopsworks`.`hdfs_command_execution`;

ALTER TABLE `hopsworks`.`executions` MODIFY COLUMN `app_id` char(30) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`maggy_driver` MODIFY COLUMN `app_id` char(30) COLLATE latin1_general_cs NOT NULL;
