DROP TABLE IF EXISTS `hopsworks`.`system_commands`;

-- ALTER TABLE `hopsworks`.`jobs` DROP INDEX `name_project_idx` , ADD UNIQUE INDEX `name_idx` (`name` ASC);

DROP TABLE IF EXISTS `pia`;

ALTER TABLE `hopsworks`.`jupyter_settings` DROP COLUMN `shutdown_level`;

DROP TABLE IF EXISTS `hopsworks`.`rstudio_settings`;
DROP TABLE IF EXISTS `hopsworks`.`rstudio_project`;
DROP TABLE IF EXISTS `hopsworks`.`rstudio_interpreter`;

ALTER TABLE `hopsworks`.`tf_serving` DROP COLUMN `optimized`;
ALTER TABLE `hopsworks`.`project` DROP COLUMN `kafka_max_num_topics`;

ALTER TABLE `hopsworks`.`hosts` CHANGE COLUMN `num_gpus` `has_gpus` TINYINT(1) NOT NULL DEFAULT 0;
ALTER TABLE `hopsworks`.`hosts` DROP COLUMN `conda_enabled`

--
-- Exporting Anaconda environment as yml
--
ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN `environment_yml`;

ALTER TABLE `hopsworks`.`jupyter_settings` DROP COLUMN `fault_tolerant`;
