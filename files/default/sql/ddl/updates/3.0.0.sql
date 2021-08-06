ALTER TABLE `hopsworks`.`on_demand_feature` ADD COLUMN `idx` int(11) NOT NULL DEFAULT 0;

DROP TABLE `hopsworks`.`ndb_backup`;

DROP TABLE `project_devices`; 
DROP TABLE `project_devices_settings`; 

ALTER TABLE `hopsworks`.`dataset_shared_with` ADD COLUMN `shared_by` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`dataset_shared_with` ADD COLUMN `accepted_by` INT(11) DEFAULT NULL;

ALTER TABLE `hopsworks`.`dataset_shared_with` ADD CONSTRAINT `fk_shared_by` FOREIGN KEY (`shared_by`) REFERENCES `users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`dataset_shared_with` ADD CONSTRAINT `fk_accepted_by` FOREIGN KEY (`accepted_by`) REFERENCES `users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION;
