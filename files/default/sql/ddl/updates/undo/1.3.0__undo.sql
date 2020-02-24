ALTER TABLE `hopsworks`.`shared_topics` DROP COLUMN `accepted`;


ALTER TABLE `hopsworks`.`external_training_dataset` DROP COLUMN `path`;

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `hdfs_user_id` int(11) NOT NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `fk_hdfs_user_id` FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;