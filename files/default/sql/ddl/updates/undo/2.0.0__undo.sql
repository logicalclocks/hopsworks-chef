DROP TABLE IF EXISTS `feature_store_statistic`;

CREATE TABLE `featurestore_statistic` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `feature_group_id` int(11) DEFAULT NULL,
  `training_dataset_id` int(11) DEFAULT NULL,
  `name` varchar(500) COLLATE latin1_general_cs DEFAULT NULL,
  `statistic_type` int(11) NOT NULL DEFAULT '0',
  `value` varchar(13300) COLLATE latin1_general_cs NOT NULL,
  PRIMARY KEY (`id`),
  KEY `feature_group_id` (`feature_group_id`),
  KEY `training_dataset_id` (`training_dataset_id`),
  CONSTRAINT `FK_693_956` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_812_957` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `cluster_analysis_enabled` TINYINT(1) NOT NULL DEFAULT '1';
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN`num_clusters` int(11) NOT NULL DEFAULT '5';
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `num_bins` INT(11) NOT NULL DEFAULT '20';
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `corr_method` VARCHAR(50) NOT NULL DEFAULT 'pearson';