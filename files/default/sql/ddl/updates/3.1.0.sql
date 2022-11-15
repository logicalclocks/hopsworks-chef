-- time series split
ALTER TABLE `hopsworks`.`training_dataset_split` ADD COLUMN `split_type` VARCHAR(40) NULL;
ALTER TABLE `hopsworks`.`training_dataset_split` ADD COLUMN `start_time` TIMESTAMP NULL;
ALTER TABLE `hopsworks`.`training_dataset_split` ADD COLUMN `end_Time` TIMESTAMP NULL;
ALTER TABLE `hopsworks`.`training_dataset_split` MODIFY COLUMN `percentage` float NULL;

-- remove anaconda_repo
ALTER TABLE `hopsworks`.`python_dep` ADD COLUMN `repo_url` varchar(255) CHARACTER SET latin1 COLLATE
    latin1_general_cs NOT NULL;
SET SQL_SAFE_UPDATES = 0;
UPDATE python_dep p SET repo_url=(SELECT url FROM anaconda_repo WHERE id = p.repo_id);
SET SQL_SAFE_UPDATES = 1;
alter table `hopsworks`.`python_dep` drop foreign key `FK_501_510`, drop column `repo_id`;
alter table `hopsworks`.`python_dep` drop index `dependency`;
DROP TABLE `anaconda_repo`;
ALTER TABLE `hopsworks`.`python_dep` ADD CONSTRAINT `dependency` UNIQUE (`dependency`,`version`,`install_type`,
                                                                         `repo_url`);

-- add tutorial endpoint
CREATE TABLE IF NOT EXISTS `tutorial` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `idx` INT(5) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `github_path` VARCHAR(200) NOT NULL,
    `description` VARCHAR(200) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `model_framework` INT(11) NOT NULL;

CREATE TABLE IF NOT EXISTS `pki_certificate` (
  `ca` TINYINT NOT NULL,
  `serial_number` BIGINT NOT NULL,
  `status` TINYINT NOT NULL,
  `subject` VARCHAR(255) NOT NULL,
  `certificate` VARBINARY(10000),
  `not_before` DATETIME NOT NULL,
  `not_after` DATETIME NOT NULL,
  PRIMARY KEY(`status`, `subject`) USING HASH,
  KEY `sn_index` (`serial_number`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `pki_crl` (
  `type` VARCHAR(20) NOT NULL,
  `crl` MEDIUMBLOB NOT NULL,
  PRIMARY KEY(`type`) USING HASH
) /*!50100 TABLESPACE `ts_1` STORAGE DISK */ ENGINE=ndbcluster COMMENT='NDB_TABLE=READ_BACKUP=1' DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `pki_key` (
	`owner` VARCHAR(100) NOT NULL,
	`type` TINYINT NOT NULL,
	`key` VARBINARY(8192) NOT NULL,
	PRIMARY KEY (`owner`, `type`) USING HASH
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `pki_serial_number` (
  `type` VARCHAR(20) NOT NULL,
  `number` BIGINT NOT NULL,
  PRIMARY KEY(`type`) USING HASH
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

DROP TABLE `dela`;
DROP TABLE `hopssite_cluster_certs`;

-- rename transformation functions output types
SET SQL_SAFE_UPDATES = 0;
UPDATE transformation_function
SET output_type = 'STRING'
WHERE output_type = 'StringType()';

UPDATE transformation_function
SET output_type = 'BINARY'
WHERE output_type = 'BinaryType()';

UPDATE transformation_function
SET output_type = 'BYTE'
WHERE output_type = 'ByteType()';

UPDATE transformation_function
SET output_type = 'SHORT'
WHERE output_type = 'ShortType()';

UPDATE transformation_function
SET output_type = 'INT'
WHERE output_type = 'IntegerType()';

UPDATE transformation_function
SET output_type = 'LONG'
WHERE output_type = 'LongType()';

UPDATE transformation_function
SET output_type = 'FLOAT'
WHERE output_type = 'FloatType()';

UPDATE transformation_function
SET output_type = 'DOUBLE'
WHERE output_type = 'DoubleType()';

UPDATE transformation_function
SET output_type = 'TIMESTAMP'
WHERE output_type = 'TimestampType()';

UPDATE transformation_function
SET output_type = 'DATE'
WHERE output_type = 'DateType()';

UPDATE transformation_function
SET output_type = 'BOOLEAN'
WHERE output_type = 'BooleanType()';
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`feature_store_activity` DROP COLUMN `execution_last_event_time`;

-- activity great expectations data validation
ALTER TABLE `hopsworks`.`feature_store_activity` ADD COLUMN `validation_report_id` Int(11) NULL;
ALTER TABLE `hopsworks`.`feature_store_activity` ADD CONSTRAINT `fs_act_validationreport_fk` FOREIGN KEY (`validation_report_id`) REFERENCES `validation_report` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`feature_store_activity` ADD COLUMN `expectation_suite_id` Int(11) NULL;
ALTER TABLE `hopsworks`.`feature_store_activity` ADD CONSTRAINT `fs_act_expectationsuite_fk` FOREIGN KEY (`expectation_suite_id`) REFERENCES `expectation_suite` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;


ALTER TABLE `hopsworks`.`project` ADD COLUMN `creation_status` TINYINT(1) NOT NULL DEFAULT '0';
