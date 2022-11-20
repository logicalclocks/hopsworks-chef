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

-- Validation Result history FSTORE-341
ALTER TABLE `hopsworks`.`validation_result` ADD COLUMN `validation_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE `hopsworks`.`validation_result` ADD COLUMN `ingestion_result` VARCHAR(8) NOT NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`validation_result` SET `validation_time`=(SELECT `validation_time` FROM `hopsworks`.`validation_report` WHERE `hopsworks`.`validation_result`.`validation_report_id` = `hopsworks`.`validation_report`.`id`);
UPDATE `hopsworks`.`validation_result` SET `ingestion_result`=(SELECT `ingestion_result` FROM `hopsworks`.`validation_report` WHERE `hopsworks`.`validation_result`.`validation_report_id` = `hopsworks`.`validation_report`.`id`);
SET SQL_SAFE_UPDATES = 1;

-- FSTORE-442
ALTER TABLE `hopsworks`.`expectation` MODIFY COLUMN `kwargs` VARCHAR(5000) NOT NULL;

-- BEGIN CHANGES FSTORE-326
-- bigquery
ALTER TABLE `feature_store_bigquery_connector`
    DROP FOREIGN KEY `fk_fs_storage_connector_bigq_keyfile`;
ALTER TABLE `feature_store_bigquery_connector`
    ADD CONSTRAINT `fk_fs_storage_connector_bigq_keyfile`
        FOREIGN KEY (`key_inode_pid`, `key_inode_name`, `key_partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
            ON DELETE SET NULL ON UPDATE NO ACTION;
-- gcs
ALTER TABLE `feature_store_gcs_connector`
    DROP FOREIGN KEY `fk_fs_storage_connector_gcs_keyfile`;
ALTER TABLE `feature_store_gcs_connector`
    ADD CONSTRAINT `fk_fs_storage_connector_gcs_keyfile`
        FOREIGN KEY (`key_inode_pid`, `key_inode_name`, `key_partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
            ON DELETE SET NULL ON UPDATE NO ACTION;
-- kafka
ALTER TABLE `feature_store_kafka_connector`
    DROP FOREIGN KEY `fk_fs_storage_connector_kafka_keystore`,
    DROP FOREIGN KEY `fk_fs_storage_connector_kafka_truststore`;
ALTER TABLE `feature_store_kafka_connector`
    ADD CONSTRAINT `fk_fs_storage_connector_kafka_keystore`
        FOREIGN KEY (`keystore_inode_pid`, `keystore_inode_name`, `keystore_partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
            ON DELETE SET NULL ON UPDATE NO ACTION,
    ADD CONSTRAINT `fk_fs_storage_connector_kafka_truststore`
        FOREIGN KEY (`truststore_inode_pid`, `truststore_inode_name`,
                     `truststore_partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
            ON DELETE SET NULL ON UPDATE NO ACTION;
-- END CHANGES FSTORE-326

-- CHANGES HWORKS-262
DROP TABLE `hopsworks`.`message_to_user`;

-- to avoid repeating the same code 100s of time we create a procedure here
DROP PROCEDURE IF EXISTS REPLACE_EMAIL_FK;

DELIMITER //

CREATE PROCEDURE REPLACE_EMAIL_FK(IN table_name VARCHAR(100), 
                                  IN old_column_name VARCHAR(100), IN new_column_name VARCHAR(100),
                                  IN old_fk_ref_table VARCHAR(100),
                                  IN index_name VARCHAR(100), IN fk_name VARCHAR(100))
BEGIN
    -- add the new column 
    SET @s := concat('ALTER TABLE hopsworks.', table_name, ' ADD COLUMN `', new_column_name ,'` INT(11)');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    -- update the uid values based on the emails
    SET SQL_SAFE_UPDATES = 0;
    SET @s := concat('UPDATE hopsworks.', table_name, ' t JOIN `hopsworks`.`users` u ON t.', old_column_name
                    , ' = u.email SET t.', new_column_name ,'= u.uid');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;
    SET SQL_SAFE_UPDATES = 1;

    -- now that the column has been populated, modify it to be not null
    -- this is needed to be able to build some unique indices/primary keys for some tables
    SET @s := concat('ALTER TABLE hopsworks.', table_name, ' MODIFY COLUMN `', new_column_name ,'` INT(11) NOT NULL');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;
    
    -- add fk constraint to the users table
    SET @s := concat('ALTER TABLE hopsworks.', table_name, ' ADD CONSTRAINT `', fk_name
                    , '` FOREIGN KEY (`', new_column_name 
                    ,'`) REFERENCES `hopsworks`.`users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    -- drop the existing foreign key  
    SET @fk_name = (SELECT k.CONSTRAINT_NAME 
	FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE k 
	WHERE k.TABLE_SCHEMA = "hopsworks" AND k.TABLE_NAME = table_name AND k.COLUMN_NAME = old_column_name AND k.REFERENCED_TABLE_NAME=old_fk_ref_table);

    SET @s := concat('ALTER TABLE hopsworks.', table_name , ' DROP FOREIGN KEY `', @fk_name, '`');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    -- drop the index created by the foreign key
    SET @s := concat('ALTER TABLE hopsworks.', table_name, ' DROP KEY `', index_name, '`');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    IF table_name = "jobs" THEN
        -- need to do it at this stage. earlier and the index is used by the old fk
        -- later and we can't drop the column as there is an index assigned to it
        ALTER TABLE `hopsworks`.`jobs` DROP KEY `creator_project_idx`;
    END IF;

    -- drop the original column
    SET @s := concat('ALTER TABLE hopsworks.', table_name, ' DROP COLUMN `', old_column_name, '`');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

END //

DELIMITER ;

-- welcome to the jungle.

CALL REPLACE_EMAIL_FK('jobs', 'creator', 'uid', 'users', 'creator', 'user_fk_executions');
-- add the index back, but with the UID column 
ALTER TABLE `hopsworks`.`jobs` ADD KEY `uid_project_idx`(`uid`, `project_id`);

CALL REPLACE_EMAIL_FK('executions', 'user', 'uid', 'users', 'user', 'user_fk_executions');


-- dataset_request table has a FK to the project_team table that references project_id and email
-- we need to clean up the email from the dataset_request first then migrate the project_team
-- table and then add back the FK to the dataset_request table pointing to the new uid column
CALL REPLACE_EMAIL_FK('dataset_request', 'user_email', 'uid', 'project_team', 'projectId', 'project_team_fk');

-- the primary key for the project team table should be re-created to use uid instead of email
ALTER TABLE `hopsworks`.`project_team` DROP PRIMARY KEY;
-- migrate the column
CALL REPLACE_EMAIL_FK('project_team', 'team_member', 'uid', 'users', 'team_member', 'user_fk_team');
-- add back the primary key using the uid column 
ALTER TABLE `hopsworks`.`project_team` ADD PRIMARY KEY(`project_id`, `uid`);

-- drop the foreign key created by the procedure above for dataset_request
-- and the proper one. This is done here to avoid having too much complexity 
-- on the stored procedure
ALTER TABLE `hopsworks`.`dataset_request` DROP FOREIGN KEY project_team_fk;
ALTER TABLE `hopsworks`.`dataset_request` DROP KEY project_team_fk;
ALTER TABLE `hopsworks`.`dataset_request`
    ADD CONSTRAINT `project_team_fk_ds` FOREIGN KEY (`projectId`,`uid`) 
    REFERENCES `project_team` (`project_id`,`uid`) ON DELETE CASCADE ON UPDATE NO ACTION;

-- These are the easy ones that should not get tangled 
CALL REPLACE_EMAIL_FK('project', 'username', 'uid', 'users', 'user_idx', 'user_fk_project');
CALL REPLACE_EMAIL_FK('topic_acls', 'username', 'uid', 'users', 'username', 'user_fk_kafka_acls');
CALL REPLACE_EMAIL_FK('jupyter_settings', 'team_member', 'uid', 'users', 'team_member', 'user_fk_jp_settings');
CALL REPLACE_EMAIL_FK('rstudio_settings', 'team_member', 'uid', 'users', 'team_member', 'user_fk_jp_settings');
CALL REPLACE_EMAIL_FK('message', 'user_from', 'uid_from', 'users', 'user_from', 'user_fk_msg_from');
CALL REPLACE_EMAIL_FK('message', 'user_to', 'uid_to', 'users', 'user_to', 'user_fk_msg_to');

-- END CHANGES HWORKS-262