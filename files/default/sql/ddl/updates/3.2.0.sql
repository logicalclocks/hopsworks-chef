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
    CONSTRAINT `job_monitoring_config_fk` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `detection_window_config_monitoring_config_fk` FOREIGN KEY (`detection_window_config_id`) REFERENCES `monitoring_window_config` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `reference_window_config_monitoring_config_fk` FOREIGN KEY (`reference_window_config_id`) REFERENCES `monitoring_window_config` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `statistics_comparison_config_monitoring_config_fk` FOREIGN KEY (`statistics_comparison_config_id`) REFERENCES `statistics_comparison_config` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_descriptive_statistics` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `feature_type` varchar(20) NOT NULL,
    -- for any feature type
    `count` BIGINT NOT NULL,
    `completeness` FLOAT NULL,
    `num_non_null_values` BIGINT NULL,
    `num_null_values` BIGINT NULL,
    `approx_num_distinct_values` BIGINT NULL,
    -- for numerical features
    `min` FLOAT NULL,
    `max` FLOAT NULL,
    `sum` FLOAT NULL,
    `mean` FLOAT NULL,
    `stddev` FLOAT NULL,
    `percentiles` BLOB,
    -- with exactUniqueness
    `distinctness` FLOAT NULL,
    `entropy` FLOAT NULL,
    `uniqueness` FLOAT NULL,
    `exact_num_distinct_values` BIGINT NULL,
    -- for filtering
    `start_time` TIMESTAMP NULL,    -- commit time
    `end_time` TIMESTAMP NOT NULL,  -- commit time
    `row_percentage` INT(11) NOT NULL,
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
    CONSTRAINT `config_monitoring_result_fk` FOREIGN KEY (`feature_monitoring_config_id`) REFERENCES `feature_monitoring_config` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `detection_stats_monitoring_result_fk` FOREIGN KEY (`detection_stats_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION,
    CONSTRAINT `reference_stats_monitoring_result_fk` FOREIGN KEY (`reference_stats_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION
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
