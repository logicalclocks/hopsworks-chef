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