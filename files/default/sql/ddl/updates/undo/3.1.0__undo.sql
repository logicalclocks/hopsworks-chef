-- time series split
ALTER TABLE `hopsworks`.`training_dataset_split` DROP COLUMN `split_type`;
ALTER TABLE `hopsworks`.`training_dataset_split` DROP COLUMN `start_time`;
ALTER TABLE `hopsworks`.`training_dataset_split` DROP COLUMN `end_Time`;
ALTER TABLE `hopsworks`.`training_dataset_split` MODIFY COLUMN `percentage` float NOT NULL;

-- Add anaconda_repo
CREATE TABLE `anaconda_repo` (
                                 `id` int(11) NOT NULL AUTO_INCREMENT,
                                 `url` varchar(255) COLLATE latin1_general_cs NOT NULL,
                                 PRIMARY KEY (`id`),
                                 UNIQUE KEY `url` (`url`)
) ENGINE=ndbcluster AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
INSERT INTO `anaconda_repo`(`url`) SELECT DISTINCT `repo_url` FROM `python_dep`;
ALTER TABLE `hopsworks`.`python_dep` ADD COLUMN `repo_id` INT(11) NOT NULL;
SET SQL_SAFE_UPDATES = 0;
UPDATE `python_dep` `p` SET `repo_id`=(SELECT `id` FROM `anaconda_repo` WHERE `url` = `p`.`repo_url`);
SET SQL_SAFE_UPDATES = 1;
ALTER TABLE `python_dep` ADD CONSTRAINT `FK_501_510` FOREIGN KEY (`repo_id`) REFERENCES `anaconda_repo` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`python_dep` DROP INDEX `dependency`;
ALTER TABLE `hopsworks`.`python_dep` DROP COLUMN `repo_url`;
ALTER TABLE `hopsworks`.`python_dep` ADD CONSTRAINT `dependency` UNIQUE (`dependency`,`version`,`install_type`,
                                                                         `repo_id`);

-- add tutorial endpoint
DROP TABLE IF EXISTS `hopsworks`.`tutorial`;

ALTER TABLE `hopsworks`.`serving` DROP COLUMN `model_framework`;
DROP TABLE IF EXISTS `hopsworks`.`pki_certificate`;
DROP TABLE IF EXISTS `hopsworks`.`pki_crl`;
DROP TABLE IF EXISTS `hopsworks`.`pki_key`;
DROP TABLE IF EXISTS `hopsworks`.`pki_serial_number`;
