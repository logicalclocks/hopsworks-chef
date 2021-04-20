ALTER TABLE `hopsworks`.`serving` ADD COLUMN `deployed` timestamp DEFAULT NULL;
ALTER TABLE `hopsworks`.`serving` ADD COLUMN `revision` VARCHAR(8) DEFAULT NULL;