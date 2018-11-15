ALTER TABLE `hopsworks`.`project` ADD COLUMN `conda_env` TINYINT(1) DEFAULT 0;
UPDATE `hopsworks`.`project` SET conda_env=1 WHERE conda=1;
