ALTER TABLE `hopsworks`.`python_dep` DROP COLUMN `base_env`;
ALTER TABLE `hopsworks`.`conda_commands` ADD COLUMN `host_id` int(11) NOT NULL;
ALTER TABLE `hopsworks`.`conda_commands` ADD KEY (`host_id`);
ALTER TABLE `hopsworks`.`conda_commands` ADD CONSTRAINT `FK_481_519` FOREIGN KEY (`host_id`) REFERENCES `hosts` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION ;
ALTER TABLE `hopsworks`.`conda_commands` CHANGE `docker_image` `proj` varchar(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`jupyter_project` CHANGE `cid` `pid` bigint(20) NOT NULL;
ALTER TABLE `hopsworks`.`tensorboard` CHANGE `cid` `pid` bigint(20) NOT NULL;
ALTER TABLE `hopsworks`.`serving` CHANGE `cid` `local_pid` bigint(20) NOT NULL;
ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN `error_message`;
ALTER TABLE `hopsworks`.`conda_commands` CHANGE `environment_yml` `environment_yml` VARCHAR(10000) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`jupyter_settings` CHANGE COLUMN `base_dir` `base_dir` varchar(255) COLLATE latin1_general_cs DEFAULT '/Jupyter/';

UPDATE `hopsworks`.`jupyter_settings` `j`
JOIN `hopsworks`.`project` `p`
ON `j`.`project_id` = `p`.`id`
SET `j`.`base_dir` = '/Jupyter/';