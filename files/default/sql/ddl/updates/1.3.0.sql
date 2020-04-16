ALTER TABLE `hopsworks`.`shared_topics` ADD COLUMN `accepted` tinyint(1) NOT NULL DEFAULT '0';
SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`shared_topics` SET accepted=1;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`external_training_dataset` ADD COLUMN `path` VARCHAR(10000);

-- Find the name of the FK
SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "training_dataset" AND REFERENCED_TABLE_NAME="hdfs_users");
SET @s := concat('ALTER TABLE hopsworks.training_dataset DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `hdfs_user_id`; 

ALTER TABLE `hopsworks`.`feature_store_feature` MODIFY COLUMN `description` VARCHAR(10000) COLLATE latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_store_tag` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `name` varchar(255) NOT NULL,
      `type` varchar(45) NOT NULL DEFAULT 'STRING',
      PRIMARY KEY (`id`),
      UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`host_services` CHANGE COLUMN `service` `name` varchar(48) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`host_services` ADD UNIQUE KEY `service_UNIQUE` (`host_id`, `name`);

DELETE FROM `hopsworks`.`jobs` WHERE type="BEAM_FLINK";

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `seed` BIGINT NULL;

CREATE TABLE IF NOT EXISTS `training_dataset_split` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `training_dataset_id` int(11) NOT NULL,
  `name` varchar(1000) COLLATE latin1_general_cs NOT NULL,
  `percentage` float NOT NULL,
  PRIMARY KEY (`id`),
  KEY `training_dataset_id` (`training_dataset_id`),
  CONSTRAINT `training_dataset_fk` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
