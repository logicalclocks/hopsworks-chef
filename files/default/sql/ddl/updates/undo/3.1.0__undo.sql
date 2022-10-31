-- time series split
ALTER TABLE `hopsworks`.`training_dataset_split` DROP COLUMN `split_type`;
ALTER TABLE `hopsworks`.`training_dataset_split` DROP COLUMN `start_time`;
ALTER TABLE `hopsworks`.`training_dataset_split` DROP COLUMN `end_Time`;
ALTER TABLE `hopsworks`.`training_dataset_split` MODIFY COLUMN `percentage` float NOT NULL;

-- Add anaconda_repo
CREATE TABLE `anaconda_repo` (
                                 `id` int(11) NOT NULL AUTO_INCREMENT,
                                 `url` varchar(255) COLLATE latin1_general_cs NOT NULL,
                                 PRIMARY KEY (`id`),
                                 UNIQUE KEY `url` (`url`)
) ENGINE=ndbcluster AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
INSERT INTO `anaconda_repo`(`url`) SELECT DISTINCT `repo_url` FROM `python_dep`;
ALTER TABLE `hopsworks`.`python_dep` ADD COLUMN `repo_id` INT(11) NOT NULL;
SET SQL_SAFE_UPDATES = 0;
UPDATE `python_dep` `p` SET `repo_id`=(SELECT `id` FROM `anaconda_repo` WHERE `url` = `p`.`repo_url`);
SET SQL_SAFE_UPDATES = 1;
ALTER TABLE `python_dep` ADD CONSTRAINT `FK_501_510` FOREIGN KEY (`repo_id`) REFERENCES `anaconda_repo` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`python_dep` DROP INDEX `dependency`;
ALTER TABLE `hopsworks`.`python_dep` DROP COLUMN `repo_url`;
ALTER TABLE `hopsworks`.`python_dep` ADD CONSTRAINT `dependency` UNIQUE (`dependency`,`version`,`install_type`,
                                                                         `repo_id`);

-- add tutorial endpoint
DROP TABLE IF EXISTS `hopsworks`.`tutorial`;


ALTER TABLE `hopsworks`.`serving` DROP COLUMN `model_framework`;
DROP TABLE IF EXISTS `hopsworks`.`pki_certificate`;
DROP TABLE IF EXISTS `hopsworks`.`pki_crl`;
DROP TABLE IF EXISTS `hopsworks`.`pki_key`;
DROP TABLE IF EXISTS `hopsworks`.`pki_serial_number`;

--
-- Table structure for table `dela`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dela` (
                        `id` varchar(200) COLLATE latin1_general_cs NOT NULL,
                        `did` int(11) NOT NULL,
                        `pid` int(11) NOT NULL,
                        `name` varchar(200) COLLATE latin1_general_cs NOT NULL,
                        `status` varchar(52) COLLATE latin1_general_cs NOT NULL,
                        `stream` varchar(200) COLLATE latin1_general_cs DEFAULT NULL,
                        `partners` varchar(200) COLLATE latin1_general_cs DEFAULT NULL,
                        PRIMARY KEY (`id`),
                        KEY `did` (`did`),
                        CONSTRAINT `FK_429_542` FOREIGN KEY (`did`) REFERENCES `dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hopssite_cluster_certs`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hopssite_cluster_certs` (
                                          `cluster_name` varchar(129) COLLATE latin1_general_cs NOT NULL,
                                          `cluster_key` varbinary(7000) DEFAULT NULL,
                                          `cluster_cert` varbinary(3000) DEFAULT NULL,
                                          `cert_password` varchar(200) COLLATE latin1_general_cs NOT NULL DEFAULT '',
                                          PRIMARY KEY (`cluster_name`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;


-- rename transformation functions output types
SET SQL_SAFE_UPDATES = 0;
UPDATE transformation_function
SET output_type = 'StringType()'
WHERE output_type = 'STRING';

UPDATE transformation_function
SET output_type = 'BinaryType()'
WHERE output_type = 'BINARY';

UPDATE transformation_function
SET output_type = 'ByteType()'
WHERE output_type = 'BYTE';

UPDATE transformation_function
SET output_type = 'ShortType()
WHERE output_type = 'SHORT'';

UPDATE transformation_function
SET output_type = 'IntegerType()'
WHERE output_type = 'INT';

UPDATE transformation_function
SET output_type = 'LongType()'
WHERE output_type = 'LONG';

UPDATE transformation_function
SET output_type = 'FloatType()'
WHERE output_type = 'FLOAT';

UPDATE transformation_function
SET output_type = 'DoubleType()'
WHERE output_type = 'DOUBLE';

UPDATE transformation_function
SET output_type = 'TimestampType()'
WHERE output_type = 'TIMESTAMP';

UPDATE transformation_function
SET output_type = 'DateType()'
WHERE output_type = 'DATE';

UPDATE transformation_function
SET output_type = 'BooleanType()'
WHERE output_type = 'BOOLEAN';
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`feature_store_activity` ADD COLUMN `execution_last_event_time` BIGINT(20) NULL;

-- activity great expectations data validation
ALTER TABLE `hopsworks`.`feature_store_activity` DROP CONSTRAINT `fs_act_expectationsuite_fk` FOREIGN KEY (`expectation_suite_id`) REFERENCES `expectation_suite` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`feature_store_activity` DROP CONSTRAINT `fs_act_validationreport_fk` FOREIGN KEY (`validation_report_id`) REFERENCES `validation_report` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`feature_store_activity` DROP COLUMN `validation_report_id` Int(11) NULL;
ALTER TABLE `hopsworks`.`feature_store_activity` DROP COLUMN `expectation_suite_id` Int(11) NULL;
