-- time series split
ALTER TABLE `hopsworks`.`training_dataset_split` ADD COLUMN `split_type` VARCHAR(40) NULL;
ALTER TABLE `hopsworks`.`training_dataset_split` ADD COLUMN `start_time` TIMESTAMP NULL;
ALTER TABLE `hopsworks`.`training_dataset_split` ADD COLUMN `end_Time` TIMESTAMP NULL;
ALTER TABLE `hopsworks`.`training_dataset_split` MODIFY COLUMN `percentage` float NULL;

CREATE TABLE IF NOT EXISTS `feature_group_link` (
  `id` int NOT NULL AUTO_INCREMENT,
  `feature_group_id` int(11) NOT NULL,
  `parent_feature_group_id` int(11),
  `parent_feature_store` varchar(100) NOT NULL,
  `parent_feature_group_name` varchar(63) NOT NULL,
  `parent_feature_group_version` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `link_unique` (`feature_group_id`,`parent_feature_group_id`),
  KEY `feature_group_id_fkc` (`feature_group_id`),
  KEY `parent_feature_group_id_fkc` (`parent_feature_group_id`),
  CONSTRAINT `feature_group_id_fkc` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `feature_group_parent_fkc` FOREIGN KEY (`parent_feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_view_link` (
  `id` int NOT NULL AUTO_INCREMENT,
  `feature_view_id` int(11) NOT NULL,
  `parent_feature_group_id` int(11),
  `parent_feature_store` varchar(100) NOT NULL,
  `parent_feature_group_name` varchar(63) NOT NULL,
  `parent_feature_group_version` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `link_unique` (`feature_view_id`,`parent_feature_group_id`),
  KEY `feature_view_id_fkc` (`feature_view_id`),
  KEY `feature_view_parent_id_fkc` (`parent_feature_group_id`),
  CONSTRAINT `feature_view_id_fkc` FOREIGN KEY (`feature_view_id`) REFERENCES `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `feature_view_parent_fkc` FOREIGN KEY (`parent_feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
