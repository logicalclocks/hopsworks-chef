ALTER TABLE `hopsworks`.`on_demand_feature_group` ADD COLUMN `name` VARCHAR(1000);

-- Add all the names from on_demand feature groups
UPDATE `hopsworks`.`feature_group` `f` 
JOIN `hopsworks`.`on_demand_feature_group` `o` 
ON `f`.`on_demand_feature_group_id` = `o`.`id`
SET `o`.`name` = `f`.`name`;

ALTER TABLE `hopsworks`.`feature_group` 
    DROP INDEX `name_key`,
    DROP COLUMN `name`;

ALTER TABLE `hopsworks`.`external_training_dataset` ADD COLUMN `name` VARCHAR(256);

UPDATE `hopsworks`.`training_dataset` `t`
JOIN `hopsworks`.`external_training_dataset` `e`
ON `t`.`external_training_dataset_id` = `e`.`id`
SET `e`.`name` = `t`.`name`;

ALTER TABLE `hopsworks`.`training_datset` 
    DROP INDEX `name_key`,
    DROP COLUMN `name`;

ALTER TABLE `hopsworks`.`host_services` DROP KEY `service_UNIQUE`;
ALTER TABLE `hopsworks`.`host_services` CHANGE COLUMN `name` `service` varchar(48) COLLATE latin1_general_cs NOT NULL;
