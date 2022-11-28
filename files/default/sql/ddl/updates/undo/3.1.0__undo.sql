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
ALTER TABLE `hopsworks`.`feature_store_activity` DROP FOREIGN KEY `fs_act_expectationsuite_fk`;
ALTER TABLE `hopsworks`.`feature_store_activity` DROP FOREIGN KEY `fs_act_validationreport_fk`;
ALTER TABLE `hopsworks`.`feature_store_activity` DROP COLUMN `validation_report_id`;
ALTER TABLE `hopsworks`.`feature_store_activity` DROP COLUMN `expectation_suite_id`;

ALTER TABLE `hopsworks`.`project` DROP COLUMN `creation_status`;

-- Validation Result history FSTORE-341
ALTER TABLE `hopsworks`.`validation_result` DROP COLUMN `validation_time`;
ALTER TABLE `hopsworks`.`validation_result` DROP COLUMN `ingestion_result`;

-- FSTORE-442
ALTER TABLE `hopsworks`.`expectation` MODIFY COLUMN `kwargs` VARCHAR(1000) NOT NULL;

-- BEGIN CHANGES FSTORE-326
-- bigquery
ALTER TABLE `feature_store_bigquery_connector`
    DROP FOREIGN KEY `fk_fs_storage_connector_bigq_keyfile`;
ALTER TABLE `feature_store_bigquery_connector`
    ADD CONSTRAINT `fk_fs_storage_connector_bigq_keyfile`
        FOREIGN KEY (`key_inode_pid`, `key_inode_name`, `key_partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
            ON DELETE CASCADE ON UPDATE NO ACTION;
-- gcs
ALTER TABLE `feature_store_gcs_connector`
    DROP FOREIGN KEY `fk_fs_storage_connector_gcs_keyfile`;
ALTER TABLE `feature_store_gcs_connector`
    ADD CONSTRAINT `fk_fs_storage_connector_gcs_keyfile`
        FOREIGN KEY (`key_inode_pid`, `key_inode_name`, `key_partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
            ON DELETE CASCADE ON UPDATE NO ACTION ;
-- kafka
ALTER TABLE `feature_store_kafka_connector`
    DROP FOREIGN KEY `fk_fs_storage_connector_kafka_keystore`,
    DROP FOREIGN KEY `fk_fs_storage_connector_kafka_truststore`;
ALTER TABLE `feature_store_kafka_connector`
    ADD CONSTRAINT `fk_fs_storage_connector_kafka_keystore`
        FOREIGN KEY (`keystore_inode_pid`, `keystore_inode_name`, `keystore_partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
            ON DELETE CASCADE ON UPDATE NO ACTION,
    ADD CONSTRAINT `fk_fs_storage_connector_kafka_truststore`
        FOREIGN KEY (`truststore_inode_pid`, `truststore_inode_name`,
                     `truststore_partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
            ON DELETE CASCADE ON UPDATE NO ACTION;
-- END CHANGES FSTORE-326

DROP TABLE IF EXISTS `hopsworks`.`feature_group_link`;
DROP TABLE IF EXISTS `hopsworks`.`feature_view_link`;
