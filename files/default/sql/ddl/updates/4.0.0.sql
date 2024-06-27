-- FSTORE-1420
CREATE TABLE IF NOT EXISTS `hopsworks`.`hopsworks_action` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `parent_action_id` INT NULL,
  `status` VARCHAR(50) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `className` VARCHAR(255) NOT NULL,
  `methodName` VARCHAR(255) NOT NULL,
  `parameters` BLOB,
  `start_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `end_time` TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `hopsworks_action_parent_action_id_idx` (`parent_action_id`),
  CONSTRAINT `hopsworks_action_parent_action_fkc` FOREIGN KEY (`parent_action_id`) REFERENCES `hopsworks`.`hopsworks_action` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopsworks`.`hopsworks_action_attempt` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `action_id` INT NOT NULL,
  `message` varchar(1000) NOT NULL,
  `start_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `end_time` TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `hopsworks_action_attempt_action_id_fkc` FOREIGN KEY (`action_id`) REFERENCES `hopsworks`.`hopsworks_action` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
