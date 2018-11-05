--
--  TensorBoard visualization for experiments service
--
CREATE TABLE IF NOT EXISTS `tensorboard` (
  `project_id` INT(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `hdfs_user_id` int(11) NOT NULL,
  `endpoint` VARCHAR(100) NOT NULL,
  `elastic_id` VARCHAR(100) NOT NULL,
  `pid` BIGINT NOT NULL,
  `last_accessed` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hdfs_logdir` VARCHAR(10000) NOT NULL,
  PRIMARY KEY (`project_id`,`user_id`),
  FOREIGN KEY `project_id_fk` (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY `user_id_fk` (`user_id`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY `hdfs_user_id_fk` (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hosts` DROP KEY `hostname`;
ALTER TABLE `hosts` ADD UNIQUE KEY `hostname`(`hostname`);
ALTER TABLE `hosts` DROP KEY `host_ip`;
ALTER TABLE `hosts` ADD UNIQUE KEY `host_ip`(`host_ip`);

-- Remove the foreign key to the hdfs_users table
SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "tf_serving" AND REFERENCED_TABLE_NAME="hdfs_users");
SET @s := concat('ALTER TABLE hopsworks.tf_serving DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

ALTER TABLE `hopsworks`.`tf_serving` DROP INDEX `hdfs_user_idx`;

ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `status`;
ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `host_ip`;
ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `hdfs_user_id`;

ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `port` `local_port` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `pid` `local_pid` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `secret` `local_dir` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `hdfs_model_path` `model_path` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL;

ALTER TABLE `hopsworks`.`tf_serving` ADD COLUMN `instances` int(11) NOT NULL DEFAULT '0';

-- Change the fk to the user table to point to the id and not to the email
SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "tf_serving" AND REFERENCED_TABLE_NAME="users");
SET @s := concat('ALTER TABLE hopsworks.tf_serving DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `creator` `creator_old` VARCHAR(150) NOT NULL;
ALTER TABLE `hopsworks`.`tf_serving` ADD COLUMN `creator` int(11) DEFAULT NULL;

-- Disable safe updates. Update without where condition
SET SQL_SAFE_UPDATES = 0;

UPDATE `hopsworks`.`tf_serving` `t`
  JOIN `hopsworks`.`users` `u`
    ON `t`.`creator_old` = `u`.`email`
SET `t`.`creator` = `u`.`uid`;

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `creator_old`;

ALTER TABLE `hopsworks`.`tf_serving` ADD COLUMN `lock_ip` VARCHAR(15) DEFAULT NULL;
ALTER TABLE `hopsworks`.`tf_serving` ADD COLUMN `lock_timestamp` BIGINT DEFAULT NULL;

ALTER TABLE `hopsworks`.`tf_serving` ADD FOREIGN KEY `user_fk` (`creator`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Table structure for table `invalid_jwt` and `jwt_signing_key`
--
CREATE TABLE IF NOT EXISTS `invalid_jwt` (
  `jti` varchar(45) NOT NULL,
  `expiration_time` datetime NOT NULL,
  `renewable_for_sec` int(11) NOT NULL,
  PRIMARY KEY (`jti`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `jwt_signing_key` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `secret` varchar(128) NOT NULL,
  `name` varchar(45) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `jwt_signing_key_name_UNIQUE` (`name`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- Table for extended system commands arguments
CREATE TABLE IF NOT EXISTS `system_commands_args` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `command_id` BIGINT NOT NULL,
  `arguments` VARCHAR(13900) DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `command_id_idx` (`command_id`),
  FOREIGN KEY `command_id_fk` (`command_id`) REFERENCES `system_commands` (`id`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `system_commands` DROP COLUMN `arguments`;

CREATE TABLE IF NOT EXISTS `tf_lib_mapping` (
  `tf_version`      VARCHAR(20) NOT NULL,
  `cuda_version`    VARCHAR(20) NOT NULL,
  `cudnn_version`   VARCHAR(20) NOT NULL,
  `nccl_version`    VARCHAR(20) NOT NULL,
  PRIMARY KEY (`tf_version`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`project_topics` REMOVE PARTITIONING;
ALTER TABLE `hopsworks`.`project_topics` ADD CONSTRAINT `topic_project` UNIQUE (`topic_name`,`project_id`);
ALTER TABLE `hopsworks`.`project_topics` DROP PRIMARY KEY;
ALTER TABLE `hopsworks`.`project_topics` ADD COLUMN `id` INT(11) AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE `hopsworks`.`tf_serving` ADD COLUMN `kafka_topic_id` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`tf_serving` ADD CONSTRAINT `kafka_fk` FOREIGN KEY (`kafka_topic_id`) REFERENCES `hopsworks`.`project_topics`(`id`) ON DELETE SET NULL;

ALTER TABLE `hopsworks`.`tf_serving` ADD KEY `model_name_k`(`model_name`);
ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `enable_batching` `enable_batching` TINYINT(1) DEFAULT 0;
