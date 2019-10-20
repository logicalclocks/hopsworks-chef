ALTER TABLE `hopsworks`.`jobs` CHANGE COLUMN `json_config` `json_config` VARCHAR(12500) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`jupyter_settings` CHANGE COLUMN `json_config` `json_config` VARCHAR(12500) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`message` CHANGE COLUMN `content` `content` VARCHAR(11000) COLLATE latin1_general_cs NOT NULL;

ALTER TABLE `hopsworks`.`dataset`
DROP COLUMN `shared`,
DROP COLUMN `status`,
DROP COLUMN `editable`,
DROP COLUMN `inode_id`,
DROP INDEX `uq_dataset` ,
ADD UNIQUE INDEX `uq_dataset` (`inode_pid`, `inode_name`, `partition_id`),
DROP INDEX `inode_id` ;

CREATE TABLE IF NOT EXISTS `hopsworks`.`dataset_shared_with` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dataset` int(11) NOT NULL,
  `project` int(11) NOT NULL,
  `accepted` tinyint(1) NOT NULL DEFAULT '0',
  `shared_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index2` (`dataset`,`project`),
  KEY `fk_dataset_shared_with_2_idx` (`project`),
  CONSTRAINT `fk_dataset_shared_with_1` FOREIGN KEY (`dataset`) REFERENCES `dataset` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_dataset_shared_with_2` FOREIGN KEY (`project`) REFERENCES `project` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;
