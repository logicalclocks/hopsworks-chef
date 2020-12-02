DROP TABLE IF EXISTS `hopsworks`.`cached_feature`;
ALTER TABLE `hopsworks`.`feature_group_commit` MODIFY `committed_on` DATETIME;
ALTER TABLE `hopsworks`.`conda_commands` ADD CONSTRAINT `FK_284_520` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
DROP TABLE IF EXISTS `hopsworks`.`cashed_feature`;

ALTER TABLE `hopsworks`.`conda_commands` CHANGE `environment_file` `environment_yml` VARCHAR(1000) COLLATE latin1_general_cs DEFAULT NULL;