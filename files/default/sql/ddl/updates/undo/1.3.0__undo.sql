ALTER TABLE `hopsworks`.`shared_topics` DROP COLUMN `accepted`;


ALTER TABLE `hopsworks`.`external_training_dataset` DROP COLUMN `path`;

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `hdfs_user_id` int(11) NOT NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `fk_hdfs_user_id` FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`feature_store_feature` MODIFY COLUMN `description` VARCHAR(10000) COLLATE latin1_general_cs NOT NULL;

DROP TABLE IF EXISTS `feature_store_tag`;

ALTER TABLE `hopsworks`.`host_services` DROP KEY `service_UNIQUE`;
ALTER TABLE `hopsworks`.`host_services` CHANGE COLUMN `name` `service` varchar(48) COLLATE latin1_general_cs NOT NULL;

ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `seed`;

DROP TABLE IF EXISTS `training_dataset_split`;
