CREATE TABLE IF NOT EXISTS `default_job_configuration` (
  `project_id` int(11) NOT NULL,
  `type` varchar(128) COLLATE latin1_general_cs NOT NULL,
  `config` VARCHAR(12500) COLLATE latin1_general_cs DEFAULT NULL,
  PRIMARY KEY (`project_id`, `type`),
  CONSTRAINT `FK_JOBCONFIG_PROJECT` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
ALTER TABLE `hopsworks`.`serving` ADD COLUMN `deployed` timestamp DEFAULT NULL;
ALTER TABLE `hopsworks`.`serving` ADD COLUMN `revision` VARCHAR(8) DEFAULT NULL;

ALTER TABLE `hopsworks`.`validation_rule` ADD COLUMN `feature_type` VARCHAR(45) COLLATE latin1_general_cs DEFAULT NULL AFTER `accepted_type`;