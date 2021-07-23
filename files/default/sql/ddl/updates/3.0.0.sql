ALTER TABLE `hopsworks`.`on_demand_feature` ADD COLUMN `idx` int(11) NOT NULL DEFAULT 0;

ALTER TABLE `hopsworks`.`statistics_config` 
ADD COLUMN `exact_uniqueness` TINYINT(1) NOT NULL DEFAULT '1';
