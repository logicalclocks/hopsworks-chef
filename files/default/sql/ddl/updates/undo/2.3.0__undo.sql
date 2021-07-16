DROP TABLE IF EXISTS `default_job_configuration`;
ALTER TABLE `hopsworks`.`validation_rule` DROP COLUMN `feature_type`;

DROP TABLE IF EXISTS `alert_manager_config`;
DROP TABLE IF EXISTS `job_alert`;
DROP TABLE IF EXISTS `feature_group_alert`;
DROP TABLE IF EXISTS `project_service_alert`;

ALTER TABLE `hopsworks`.`training_dataset_feature` DROP FOREIGN KEY `tfn_fk_tdf`, DROP COLUMN `transformation_function`;
DROP TABLE `hopsworks`.`transformation_function`;

ALTER TABLE `hopsworks`.`training_dataset_join` DROP COLUMN `prefix`;

ALTER TABLE `hopsworks`.`serving` DROP COLUMN `docker_resource_config`;

ALTER TABLE `schemas` MODIFY COLUMN `schema` VARCHAR(10000) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL;

--
-- Table structure for table `project_devices`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_devices` (
  `project_id` int(11) NOT NULL,
  `device_uuid` varchar(36) NOT NULL,
  `password` varchar(64) NOT NULL,
  `alias` varchar(80) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `state` tinyint(1) NOT NULL DEFAULT '0',
  `last_logged_in` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`project_id`,`device_uuid`),
  CONSTRAINT `FK_284_533` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `project_devices_settings`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_devices_settings` (
  `project_id` int(11) NOT NULL,
  `jwt_secret` varchar(128) NOT NULL,
  `jwt_token_duration` int(11) NOT NULL,
  PRIMARY KEY (`project_id`),
  CONSTRAINT `FK_284_535` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;


ALTER TABLE `hopsworks`.`dataset_shared_with` DROP CONSTRAINT `fk_shared_by`;
ALTER TABLE `hopsworks`.`dataset_shared_with` DROP CONSTRAINT `fk_accepted_by`;

ALTER TABLE `hopsworks`.`dataset_shared_with` DROP COLUMN `shared_by`;
ALTER TABLE `hopsworks`.`dataset_shared_with` DROP COLUMN `accepted_by`;
