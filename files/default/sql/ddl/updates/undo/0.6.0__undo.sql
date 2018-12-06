DROP TABLE IF EXISTS `tensorboard`;

ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `status`;
ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `host_ip`;
ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `hdfs_user_id`;

ALTER TABLE `hopsworks`.`tf_serving` ADD FOREIGN KEY `hdfs_user_fk` (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `local_port` `port` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `local_pid` `pid` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `local_dir` `secret` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `model_path` `hdfs_model_path` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL;

ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `instances`;

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

ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `lock_ip`;
ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `lock_timestamp`;

ALTER TABLE `hopsworks`.`tf_serving` ADD FOREIGN KEY `user_fk` (`creator`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE NO ACTION;

DROP TABLE IF EXISTS `invalid_jwt`;
DROP TABLE IF EXISTS `jwt_signing_key`;

DROP TABLE IF EXISTS `system_commands_args`;
ALTER TABLE `system_commands` ADD COLUMN `arguments` VARCHAR(255) DEFAULT NULL AFTER `op`;

DROP TABLE IF EXISTS `tf_lib_mapping`;

ALTER TABLE `hopsworks`.`tf_serving` DROP FOREIGN KEY `kafka_fk`;
ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `kafka_topic_id`;

ALTER TABLE `hopsworks`.`project_topics` DROP PRIMARY KEY;
ALTER TABLE `hopsworks`.`project_topics` DROP COLUMN `id`;
ALTER TABLE `hopsworks`.`project_topics` ADD CONSTRAINT `project_topics_pk` PRIMARY KEY(`topic_name`,`project_id`);

ALTER TABLE `hopsworks`.`tf_serving` DROP KEY `model_name_k`;
ALTER TABLE `hopsworks`.`tf_serving` CHANGE COLUMN `enable_batching` `enable_batching` TINYINT(1) NOT NULL;
