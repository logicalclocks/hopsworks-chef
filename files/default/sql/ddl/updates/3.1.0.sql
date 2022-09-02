-- time series split
ALTER TABLE `hopsworks`.`training_dataset_split` ADD COLUMN `split_type` VARCHAR(40) NULL;
ALTER TABLE `hopsworks`.`training_dataset_split` ADD COLUMN `start_time` TIMESTAMP NULL;
ALTER TABLE `hopsworks`.`training_dataset_split` ADD COLUMN `end_Time` TIMESTAMP NULL;
ALTER TABLE `hopsworks`.`training_dataset_split` MODIFY COLUMN `percentage` float NULL;

-- remove anaconda_repo
ALTER TABLE `hopsworks`.`python_dep` ADD COLUMN `repo_url` varchar(255) CHARACTER SET latin1 COLLATE
    latin1_general_cs NOT NULL;
SET SQL_SAFE_UPDATES = 0;
UPDATE python_dep p SET repo_url=(SELECT url FROM anaconda_repo WHERE id = p.repo_id);
SET SQL_SAFE_UPDATES = 1;
alter table `hopsworks`.`python_dep` drop foreign key `FK_501_510`, drop column `repo_id`;
alter table `hopsworks`.`python_dep` drop index `dependency`;
DROP TABLE `anaconda_repo`;
ALTER TABLE `hopsworks`.`python_dep` ADD CONSTRAINT `dependency` UNIQUE (`dependency`,`version`,`install_type`,
                                                                         `repo_url`);

-- add tutorial endpoint
CREATE TABLE IF NOT EXISTS `tutorial` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `github_path` VARCHAR(200) NOT NULL,
    `single_notebook` TINYINT(1) NOT NULL,
    `description` VARCHAR(200) NOT NULL,
    `duration` VARCHAR(20) NOT NULL,
    `tags` VARCHAR(100) NOT NULL,
    `category` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;
