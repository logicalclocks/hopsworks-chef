ALTER TABLE `hopsworks`.`python_dep` ADD COLUMN `base_env` VARCHAR(45) COLLATE latin1_general_cs;

TRUNCATE TABLE `hopsworks`.`conda_commands`;
-- drop foreign key to project it is not always pointing to a project now.
SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "conda_commands" AND REFERENCED_TABLE_NAME="projects");
SET @s := concat('ALTER TABLE hopsworks.conda_commands DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;
ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN `host_id`, DROP INDEX `host_id` ;
ALTER TABLE `hopsworks`.`conda_commands` CHANGE `proj` `docker_image` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`jupyter_project` CHANGE `pid` `cid` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`tensorboard` CHANGE `pid` `cid` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`serving` CHANGE `local_pid` `cid` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`conda_commands` ADD COLUMN `error_message` VARCHAR(6000) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`conda_commands` CHANGE `environment_yml` `environment_yml` VARCHAR(6000) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`jupyter_settings` CHANGE COLUMN `base_dir` `base_dir` varchar(255) COLLATE latin1_general_cs DEFAULT NULL;

UPDATE `hopsworks`.`jupyter_settings` `j`
JOIN `hopsworks`.`project` `p`
ON `j`.`project_id` = `p`.`id`
SET `j`.`base_dir` = CONCAT('/Projects/',`p`.`projectname`,'/Jupyter');

ALTER TABLE `hopsworks`.`jupyter_git_config` ADD COLUMN `git_backend` VARCHAR(45) COLLATE latin1_general_cs DEFAULT 'GITHUB';

ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN machine_type;
ALTER TABLE `hopsworks`.`python_dep` DROP COLUMN machine_type;
ALTER TABLE `hopsworks`.`hosts` DROP COLUMN conda_enabled;