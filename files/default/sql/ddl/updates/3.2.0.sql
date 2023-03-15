ALTER TABLE `hopsworks`.`project`
    DROP COLUMN `retention_period`,
    DROP COLUMN `archived`,
    DROP COLUMN `logs`,
    DROP COLUMN `deleted`;

CREATE TABLE IF NOT EXISTS `hdfs_command_execution` (
  `id` int NOT NULL AUTO_INCREMENT,
  `execution_id` int NOT NULL,
  `command` varchar(45) NOT NULL,
  `submitted` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `src_inode_pid` bigint NOT NULL,
  `src_inode_name` varchar(255) NOT NULL,
  `src_inode_partition_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_execution_id` (`execution_id`),
  UNIQUE KEY `uq_src_inode` (`src_inode_pid`,`src_inode_name`,`src_inode_partition_id`),
  KEY `fk_hdfs_file_command_1_idx` (`execution_id`),
  KEY `fk_hdfs_file_command_2_idx` (`src_inode_partition_id`,`src_inode_pid`,`src_inode_name`),
  CONSTRAINT `fk_hdfs_file_command_1` FOREIGN KEY (`execution_id`) REFERENCES `executions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_hdfs_file_command_2` FOREIGN KEY (`src_inode_partition_id`,`src_inode_pid`,`src_inode_name`) REFERENCES `hops`.`hdfs_inodes` (`partition_id`, `parent_id`, `name`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`executions` MODIFY COLUMN `app_id` char(45) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`maggy_driver` MODIFY COLUMN `app_id` char(45) COLLATE latin1_general_cs NOT NULL;

DROP TABLE `shared_topics`;
DROP TABLE `topic_acls`;

ALTER TABLE `hopsworks`.`project_topics` ADD UNIQUE KEY `topic_name_UNIQUE` (`topic_name`);

SET SQL_SAFE_UPDATES = 0;
UPDATE `project_team`
SET team_role = 'Data owner'
WHERE team_member = 'serving@hopsworks.se';
SET SQL_SAFE_UPDATES = 1;

-- HWORKS-474: Remove hdfs_user FK from jupyter_project
ALTER TABLE `hopsworks`.`jupyter_project` ADD COLUMN `uid` INT(11);

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`jupyter_project` jp
JOIN (SELECT jpu.port AS port, u.uid AS uid
      FROM `hopsworks`.`users` u
      JOIN (
                SELECT jp.port AS port, SUBSTRING_INDEX(name, '__', -1) AS username
                FROM `hopsworks`.`jupyter_project` jp join hops.hdfs_users hu on jp.hdfs_user_id = hu.id) jpu on jpu.username = u.username) jpuid ON jp.port = jpuid.port
SET jp.uid = jpuid.uid
WHERE jp.port = jpuid.port;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`jupyter_project` ADD UNIQUE KEY `project_user` (`project_id`, `uid`);
ALTER TABLE `hopsworks`.`jupyter_project` DROP FOREIGN KEY `FK_103_525`;
ALTER TABLE `hopsworks`.`jupyter_project` DROP KEY `unique_hdfs_user`;
ALTER TABLE `hopsworks`.`jupyter_project` DROP COLUMN `hdfs_user_id`;

-- HWORKS-476: Remove hdfs_user_id FK from tensorboard
ALTER TABLE `hopsworks`.`tensorboard` DROP FOREIGN KEY `hdfs_user_id_fk`;
ALTER TABLE `hopsworks`.`tensorboard` DROP INDEX `hdfs_user_id_fk`;
ALTER TABLE `hopsworks`.`tensorboard` DROP COLUMN `hdfs_user_id`;

-- HWORKS-476: Remove hdfs_user_id FK from rstudio_project
ALTER TABLE `hopsworks`.`rstudio_project` DROP FOREIGN KEY `FK_103_577`;
ALTER TABLE `hopsworks`.`rstudio_project` DROP KEY `hdfs_user_idx`;
ALTER TABLE `hopsworks`.`rstudio_project` DROP COLUMN `hdfs_user_id`;


ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `online_enabled` TINYINT(1) NULL;
ALTER TABLE `hopsworks`.`on_demand_feature` ADD COLUMN `default_value` VARCHAR(400) NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`feature_group` `fg` 
  LEFT JOIN `cached_feature_group` `cfg` ON `fg`.`cached_feature_group_id` = `cfg`.`id`
  LEFT JOIN `stream_feature_group` `sfg` ON `fg`.`stream_feature_group_id` = `sfg`.`id`
SET `fg`.`online_enabled` = CASE WHEN `fg`.`cached_feature_group_id` IS NOT NULL THEN `cfg`.`online_enabled` WHEN `fg`.`stream_feature_group_id` IS NOT NULL THEN `sfg`.`online_enabled` ELSE 0 END;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`cached_feature_group` DROP COLUMN `online_enabled`;
ALTER TABLE `hopsworks`.`stream_feature_group` DROP COLUMN `online_enabled`;

SET max_sp_recursion_depth=10;

DROP PROCEDURE IF EXISTS `path_resolver`;
DROP FUNCTION IF EXISTS `path_resolver_fn`;

DELIMITER //
CREATE PROCEDURE path_resolver(IN `parent_id` BIGINT, 
                               OUT `inode_path` VARCHAR(255))
BEGIN
  DECLARE next_parent_id BIGINT;
  DECLARE inode_name VARCHAR(255);
  DECLARE parent_path VARCHAR(255);

  IF `parent_id` = 1 THEN
    -- We are at the root of the file system
    SET `inode_path` =  "/";
  ELSE

    -- Not the root, we need to traverse more.
    -- Get the information about the current inode
    SELECT `h`.`parent_id`, `h`.`name`
    INTO next_parent_id, inode_name
    FROM `hops`.`hdfs_inodes` `h`
    WHERE `h`.`id` = `parent_id`;

    -- Recursively traverse upstream
    CALL path_resolver(next_parent_id, parent_path);

    -- Assemble the path
    SET `inode_path` = CONCAT(parent_path, inode_name, "/");
  END IF;
END //


-- MySQL does not support recursive functions. 
-- Wrap the procedure above into a function to make the rest of the migrations easier
CREATE FUNCTION path_resolver_fn(`parent_id` BIGINT, `name` VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE parent_path VARCHAR(255);

  CALL path_resolver(`parent_id`, parent_path);

  RETURN CONCAT(parent_path, `name`);
END //

DELIMITER ;

ALTER TABLE `hopsworks`.`feature_store_kafka_connector` 
  ADD COLUMN `truststore_path` VARCHAR(255) DEFAULT NULL,
  ADD COLUMN `keystore_path` VARCHAR(255) DEFAULT NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE 
  `hopsworks`.`feature_store_kafka_connector`
SET 
  truststore_path = path_resolver_fn(`truststore_inode_pid`, `truststore_inode_name`),
  keystore_path = path_resolver_fn(`keystore_inode_pid`, `keystore_inode_name`);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`feature_store_kafka_connector` DROP FOREIGN KEY `fk_fs_storage_connector_kafka_keystore`;
ALTER TABLE `hopsworks`.`feature_store_kafka_connector` DROP KEY `fk_fs_storage_connector_kafka_keystore`;
ALTER TABLE `hopsworks`.`feature_store_kafka_connector` 
  DROP COLUMN `keystore_inode_pid`,
  DROP COLUMN `keystore_inode_name`,
  DROP COLUMN `keystore_partition_id`;

ALTER TABLE `hopsworks`.`feature_store_kafka_connector` DROP FOREIGN KEY `fk_fs_storage_connector_kafka_truststore`;
ALTER TABLE `hopsworks`.`feature_store_kafka_connector` DROP KEY `fk_fs_storage_connector_kafka_truststore`;
ALTER TABLE `hopsworks`.`feature_store_kafka_connector` 
  DROP COLUMN `truststore_inode_pid`,
  DROP COLUMN `truststore_inode_name`,
  DROP COLUMN `truststore_partition_id`;


ALTER TABLE `hopsworks`.`feature_store_gcs_connector` ADD COLUMN `key_path` VARCHAR(255) DEFAULT NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE 
  `hopsworks`.`feature_store_gcs_connector`
SET 
  key_path = path_resolver_fn(`key_inode_pid`, `key_inode_name`);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`feature_store_gcs_connector` DROP FOREIGN KEY `fk_fs_storage_connector_gcs_keyfile`;
ALTER TABLE `hopsworks`.`feature_store_gcs_connector` DROP KEY `fk_fs_storage_connector_gcs_keyfile`;
ALTER TABLE `hopsworks`.`feature_store_gcs_connector` 
  DROP COLUMN `key_inode_pid`,
  DROP COLUMN `key_inode_name`,
  DROP COLUMN `key_partition_id`;


ALTER TABLE `hopsworks`.`feature_store_bigquery_connector` ADD COLUMN `key_path` VARCHAR(255) DEFAULT NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE 
  `hopsworks`.`feature_store_bigquery_connector`
SET 
  key_path = path_resolver_fn(`key_inode_pid`, `key_inode_name`);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`feature_store_bigquery_connector` DROP FOREIGN KEY `fk_fs_storage_connector_bigq_keyfile`;
ALTER TABLE `hopsworks`.`feature_store_bigquery_connector` DROP KEY `fk_fs_storage_connector_bigq_keyfile`;
ALTER TABLE `hopsworks`.`feature_store_bigquery_connector` 
  DROP COLUMN `key_inode_pid`,
  DROP COLUMN `key_inode_name`,
  DROP COLUMN `key_partition_id`;

CREATE TABLE IF NOT EXISTS `feature_monitoring_config` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `feature_group_id` INT(11),
    `feature_view_id` INT(11),
    `feature_name` VARCHAR(63) COLLATE latin1_general_cs NOT NULL,
    `description` VARCHAR(2000) COLLATE latin1_general_cs DEFAULT NULL,
    `name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL,
    `enabled` BOOLEAN DEFAULT TRUE,
    `feature_monitoring_type` tinyint(4) NOT NULL,
    `alert_config` VARCHAR(63) COLLATE latin1_general_cs, -- dummy this should become ref to another table
    `scheduler_config` VARCHAR(63) COLLATE latin1_general_cs, -- dummy this should become ref to another table
    `job_id` INT(11) NOT NULL,
    `detection_window_config_id` INT(11),
    `reference_window_config_id` INT(11),
    `statistics_comparison_config_id` INT(11),
    PRIMARY KEY (`id`),
    KEY (`feature_name`),
    KEY (`name`),
    UNIQUE KEY `config_name_UNIQUE` (`name`, `feature_group_id`, `feature_view_id`),
    CONSTRAINT `fg_monitoring_config_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fv_monitoring_config_fk` FOREIGN KEY (`feature_view_id`) REFERENCES `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `job_monitoring_config_fk` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `monitoring_window_config` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `window_config_type` INT(11) NOT NULL,
    `specific_id` INT(11),
    `time_offset` VARCHAR(63),
    `window_length` VARCHAR(63),
    `row_percentage` INT(11),
    `specific_value` FLOAT,
    PRIMARY KEY (`id`)
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `statistics_comparison_config` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `strict` BOOLEAN DEFAULT FALSE,
    `relative` BOOLEAN DEFAULT FALSE,
    `threshold` FLOAT,
    `compare_on` INT(11) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_monitoring_result` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `feature_monitoring_config_id` INT(11) NOT NULL,
    `execution_id` INT(11) NOT NULL,  -- dummy this should become ref to another table
    `monitoring_time` timestamp DEFAULT CURRENT_TIMESTAMP,
    `shift_detected` BOOLEAN DEFAULT FALSE,
    `detection_stats_id` INT(11) NOT NULL, -- dummy this should become ref to another table
    `reference_stats_id` INT(11), -- dummy this should become ref to another table
    `difference` FLOAT,
    PRIMARY KEY (`id`),
    CONSTRAINT `config_monitoring_result_fk` FOREIGN KEY (`feature_monitoring_config_id`) REFERENCES `feature_monitoring_config` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `job_schedule` (
    `id` int NOT NULL AUTO_INCREMENT,
    `job_id` int NOT NULL,
    `start_datetime` timestamp,
    `enable` BOOLEAN NOT NULL,
    `job_frequency` varchar(20) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `job_id` (`job_id`),
    CONSTRAINT `fk_schedule_job` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE
    ) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
