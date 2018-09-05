DROP TABLE IF EXISTS `tensorboard`;

ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `status` VARCHAR(50) NOT NULL;
ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `host_ip` VARCHAR(255) DEFAULT NULL;
ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `hdfs_user_id` int(11) NOT NULL;

ALTER TABLE `hopsworks`.`tf_serving` ADD FOREIGN KEY `hdfs_user_fk` (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `local_port` `port` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `local_pid` `pid` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `local_dir` `secret` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `model_path` `hdfs_model_path` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL;

ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `instances` int(11) NOT NULL DEFAULT '0';

-- Change the fk to the user table to point to the id and not to the email
ALTER TABLE `hopsworks`.`tf_serving` DROP FOREIGN KEY `user_fk`;

ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `creator` `creator_old` int(11);
ALTER TABLE `hopsworks`.`tf_serving` ADD COLUMN `creator` int(11) DEFAULT NULL;

-- Disable safe updates. Update without where condition
SET SQL_SAFE_UPDATES = 0;

UPDATE `hopsworks`.`tf_serving` `t`
  JOIN `hopsworks`.`users` `u`
    ON `t`.`creator_old` = `u`.`uid`
SET `t`.`creator` = `u`.`email`;

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `creator_old`;

ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `lock_ip` VARCHAR(15) DEFAULT NULL;
ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `lock_timestamp` BIGINT DEFAULT NULL;

ALTER TABLE `hopsworks`.`tf_serving` ADD FOREIGN KEY `user_fk` (`creator`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE NO ACTION;
