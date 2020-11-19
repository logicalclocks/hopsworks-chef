ALTER TABLE `hopsworks`.`feature_store_tag` ADD COLUMN `type` varchar(45) NOT NULL DEFAULT 'STRING';
ALTER TABLE `hopsworks`.`feature_store_tag` DROP COLUMN `tag_schema`;