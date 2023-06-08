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

-- HWORKS-480: Remove inode foreign key from git repositories
ALTER TABLE `hopsworks`.`git_repositories` ADD COLUMN `name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`git_repositories` ADD COLUMN `path` VARCHAR(1000) COLLATE latin1_general_cs NOT NULL;

-- Migration
SET SQL_SAFE_UPDATES = 0;
UPDATE
    `hopsworks`.`git_repositories`
SET
    path = path_resolver_fn(`inode_pid`, `inode_name`);
SET SQL_SAFE_UPDATES = 1;

SET SQL_SAFE_UPDATES = 0;
UPDATE
    `hopsworks`.`git_repositories`
SET
    name = inode_name;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`git_repositories` DROP FOREIGN KEY `repository_inode_fk`;
ALTER TABLE `hopsworks`.`git_repositories` DROP KEY `repository_inode_constraint_unique`;
ALTER TABLE `hopsworks`.`git_repositories`
DROP COLUMN `inode_pid`,
    DROP COLUMN `inode_name`,
    DROP COLUMN `partition_id`;

ALTER TABLE `hopsworks`.`git_repositories` ADD UNIQUE KEY `repository_path_constraint_unique` (`path`);

-- HWORKS-515: Remove inode foreign key from feature_store_code
ALTER TABLE `hopsworks`.`feature_store_code` DROP FOREIGN KEY `inode_fk_fsc`;
ALTER TABLE `hopsworks`.`feature_store_code` DROP KEY `inode_fk_fsc`;
ALTER TABLE `hopsworks`.`feature_store_code` DROP COLUMN `inode_pid`, DROP COLUMN `partition_id`;
ALTER TABLE `hopsworks`.`feature_store_code` RENAME COLUMN `inode_name` TO `name`;

ALTER TABLE `hopsworks`.`feature_store` ADD COLUMN `name` varchar(100) COLLATE latin1_general_cs NOT NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`feature_store` `fs` 
  LEFT JOIN `project` `proj` ON `fs`.`project_id` = `proj`.`id`
SET `fs`.`name` = `proj`.`projectname`;
SET SQL_SAFE_UPDATES = 1;

-- HWORKS-486: Remove inode from project
ALTER TABLE `hopsworks`.`project` DROP FOREIGN KEY `FK_149_289`;
ALTER TABLE `hopsworks`.`project` DROP INDEX `inode_pid`;
ALTER TABLE `hopsworks`.`project` DROP COLUMN `inode_pid`;
ALTER TABLE `hopsworks`.`project` DROP COLUMN `inode_name`;
ALTER TABLE `hopsworks`.`project` DROP COLUMN `partition_id`;

-- HWORKS-526: Remove inode foreign key from validation_table
ALTER TABLE `hopsworks`.`validation_report` DROP FOREIGN KEY `inode_result_fk`;
ALTER TABLE `hopsworks`.`validation_report` DROP KEY `inode_result_fk`;
ALTER TABLE `hopsworks`.`validation_report` DROP COLUMN `inode_pid`, DROP COLUMN `partition_id`;

ALTER TABLE `hopsworks`.`validation_report` RENAME COLUMN `inode_name` TO `file_name`;

-- HWORKS-523: Remove inode foreign key from transformation_function
ALTER TABLE `hopsworks`.`transformation_function` DROP FOREIGN KEY `inode_fn_fk`;
ALTER TABLE `hopsworks`.`transformation_function` DROP KEY `inode_fn_fk`;

ALTER TABLE `hopsworks`.`transformation_function` DROP COLUMN `inode_pid`, DROP COLUMN `partition_id`, DROP COLUMN `inode_name`;

-- FSTORE-737: Remove inode foreign key from feature_group_commit
ALTER TABLE `hopsworks`.`feature_group_commit` DROP FOREIGN KEY `hopsfs_parquet_inode_fk`;
ALTER TABLE `hopsworks`.`feature_group_commit` DROP KEY `hopsfs_parquet_inode_fk`;
ALTER TABLE `hopsworks`.`feature_group_commit`
  DROP COLUMN `inode_pid`,
  DROP COLUMN `inode_name`,
  DROP COLUMN `partition_id`;

ALTER TABLE `hopsworks`.`feature_group_commit` ADD COLUMN `archived` TINYINT(1) NOT NULL DEFAULT '0';

-- FSTORE-849: Add Spline dataframe functionality
ALTER TABLE `hopsworks`.`on_demand_feature_group` 
  ADD COLUMN `spine` TINYINT(1) NOT NULL DEFAULT 0,
  MODIFY COLUMN `connector_id` INT(11) NULL;

-- HWORKS-487: Remove inode from dataset
ALTER TABLE `hopsworks`.`dataset` DROP FOREIGN KEY `FK_149_435`;
ALTER TABLE `hopsworks`.`dataset` DROP INDEX `inode_id`;
ALTER TABLE `hopsworks`.`dataset` DROP INDEX `inode_pid`;
ALTER TABLE `hopsworks`.`dataset` DROP INDEX `uq_dataset`;
ALTER TABLE `hopsworks`.`dataset` DROP COLUMN `inode_pid`;
ALTER TABLE `hopsworks`.`dataset` DROP COLUMN `inode_id`;
ALTER TABLE `hopsworks`.`dataset` DROP COLUMN `partition_id`;
ALTER TABLE `hopsworks`.`dataset` ADD KEY `dataset_name` (`inode_name`);

-- HWORKS-574: Remove inode from hdfs_command_execution
ALTER TABLE `hopsworks`.`hdfs_command_execution` DROP FOREIGN KEY `fk_hdfs_file_command_2`;
ALTER TABLE `hopsworks`.`hdfs_command_execution` DROP INDEX `fk_hdfs_file_command_2_idx`;
ALTER TABLE `hopsworks`.`hdfs_command_execution` DROP INDEX `uq_src_inode`;
ALTER TABLE `hopsworks`.`hdfs_command_execution` DROP COLUMN `src_inode_pid`;
ALTER TABLE `hopsworks`.`hdfs_command_execution` DROP COLUMN `src_inode_name`;
ALTER TABLE `hopsworks`.`hdfs_command_execution` DROP COLUMN `src_inode_partition_id`;
ALTER TABLE `hopsworks`.`hdfs_command_execution` ADD COLUMN `src_path` VARCHAR(1000) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`hdfs_command_execution` ADD UNIQUE KEY `uq_src_path` (`src_path`);

-- Feature monitoring 
CREATE TABLE IF NOT EXISTS `monitoring_window_config` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `window_config_type` INT(11) NOT NULL,
    `training_dataset_id` INT(11),
    `time_offset` VARCHAR(63),
    `window_length` VARCHAR(63),
    `row_percentage` DECIMAL(15,2),
    `specific_value` FLOAT,
    PRIMARY KEY (`id`)
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `statistics_comparison_config` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `strict` BOOLEAN DEFAULT FALSE,
    `relative` BOOLEAN DEFAULT FALSE,
    `threshold` FLOAT,
    `metric` INT(11) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `job_schedule` (
    `id` int NOT NULL AUTO_INCREMENT,
    `job_id` int NOT NULL,
    `start_datetime` timestamp,
    `enabled` BOOLEAN NOT NULL,
    `job_frequency` varchar(20) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `job_id` (`job_id`),
    CONSTRAINT `fk_schedule_job` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_monitoring_config` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `feature_group_id` INT(11),
    `feature_view_id` INT(11),
    `feature_name` VARCHAR(63) COLLATE latin1_general_cs DEFAULT NULL,
    `description` VARCHAR(2000) COLLATE latin1_general_cs DEFAULT NULL,
    `name` VARCHAR(63) COLLATE latin1_general_cs NOT NULL,
    `enabled` BOOLEAN DEFAULT TRUE,
    `is_event_time` BOOLEAN DEFAULT FALSE,
    `training_dataset_version` INT(11) DEFAULT NULL,
    `feature_monitoring_type` tinyint(4) NOT NULL,
    `scheduler_config_id` INT(11),
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
    CONSTRAINT `statistics_comparison_config_monitoring_config_fk` FOREIGN KEY (`statistics_comparison_config_id`) REFERENCES `statistics_comparison_config` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `scheduler_config_fk` FOREIGN KEY (`scheduler_config_id`) REFERENCES `job_schedule` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_descriptive_statistics` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `feature_name` VARCHAR(63) COLLATE latin1_general_cs NOT NULL,
    `feature_type` varchar(20),
    -- for any feature type
    `count` BIGINT,
    `completeness` FLOAT,
    `num_non_null_values` BIGINT,
    `num_null_values` BIGINT,
    `approx_num_distinct_values` BIGINT,
    -- for numerical features
    `min` FLOAT,
    `max` FLOAT,
    `sum` FLOAT,
    `mean` FLOAT,
    `stddev` FLOAT,
    `percentiles` BLOB,
    -- with exactUniqueness
    `distinctness` FLOAT,
    `entropy` FLOAT,
    `uniqueness` FLOAT,
    `exact_num_distinct_values` BIGINT,
    -- extended stats (hdfs file): histogram, correlations, kll
    `extended_statistics_path` VARCHAR(255),
    PRIMARY KEY (`id`),
    KEY (`feature_name`)
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

-- Create new statistics tables
CREATE TABLE IF NOT EXISTS `feature_group_statistics` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `commit_time` DATETIME(3) NOT NULL,
    `feature_group_id` INT(11) NOT NULL,
    `window_start_commit_id` BIGINT(20) DEFAULT NULL, -- window start commit id (fg)
    `window_end_commit_id` BIGINT(20) DEFAULT NULL, -- commit id or window end commit id (fg)
    `row_percentage` DECIMAL(15,2) NOT NULL DEFAULT 1.00,
    PRIMARY KEY (`id`),
    KEY `feature_group_id` (`feature_group_id`),
    KEY `window_start_commit_id_fk` (`feature_group_id`, `window_start_commit_id`),
    KEY `window_end_commit_id_fk` (`feature_group_id`, `window_end_commit_id`),
    UNIQUE KEY `window_commit_ids_row_perc_fk` (`feature_group_id`, `window_start_commit_id`, `window_end_commit_id`, `row_percentage`),
    CONSTRAINT `fgs_fg_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fgs_wec_fk` FOREIGN KEY (`feature_group_id`, `window_end_commit_id`) REFERENCES `feature_group_commit` (`feature_group_id`, `commit_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fgs_wsc_fk` FOREIGN KEY (`feature_group_id`, `window_start_commit_id`) REFERENCES `feature_group_commit` (`feature_group_id`, `commit_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_view_statistics` (
                                           `id` int(11) NOT NULL AUTO_INCREMENT,
                                           `commit_time` DATETIME(3) NOT NULL,
                                           `feature_view_id`INT(11) NOT NULL,
                                           `row_percentage` DECIMAL(15,2) NOT NULL DEFAULT 1.00,
                                           `transformed_with_version` INT(11) DEFAULT NULL, -- training dataset id whose transformation functions were applied before computing statistics
                                            -- fv statistics based on event times
                                           `window_start_event_time` BIGINT(20) DEFAULT NULL,
                                           `window_end_event_time`BIGINT(20) DEFAULT NULL,
                                           -- fv statistics based on left fg commit times
                                           `window_start_commit_time` BIGINT(20) DEFAULT NULL,
                                           `window_end_commit_time`BIGINT(20) DEFAULT NULL,
                                           PRIMARY KEY (`id`),
                                           KEY `feature_view_id` (`feature_view_id`),
                                           KEY `window_start_event_time` (`window_start_event_time`),
                                           KEY `window_end_event_time` (`window_end_event_time`),
                                           KEY `window_start_commit_time` (`window_start_commit_time`),
                                           KEY `window_end_commit_time` (`window_end_commit_time`),
                                           KEY `commit_time` (`commit_time`),
                                           UNIQUE KEY `fv_ids_window_event_times_commit_time_row_perc_fk` (`feature_view_id`, `window_start_event_time`, `window_end_event_time`, `commit_time`, `row_percentage`, `transformed_with_version`),
                                           UNIQUE KEY `fv_ids_window_commit_times_row_perc_fk` (`feature_view_id`, `window_start_commit_time`, `window_end_commit_time`, `row_percentage`, `transformed_with_version`),
                                           CONSTRAINT `fvs_fv_fk` FOREIGN KEY (`feature_view_id`) REFERENCES `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `training_dataset_statistics` (
                                           `id` int(11) NOT NULL AUTO_INCREMENT,
                                           `commit_time` DATETIME(3) NOT NULL,
                                           `training_dataset_id`INT(11) NOT NULL,
                                           `for_transformation` TINYINT(1) DEFAULT '0',
                                           `row_percentage` DECIMAL(15,2) NOT NULL DEFAULT 1.00,
                                           PRIMARY KEY (`id`),
                                           KEY `training_dataset_id` (`training_dataset_id`),
                                           UNIQUE KEY `tr_ids_for_trans_row_perc_fk` (`training_dataset_id`, `for_transformation`, `row_percentage`),
                                           CONSTRAINT `tds_td_fk` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- TODO: SQL Queries for populating new tables based on feature_store_statistic table.

-- Update feature_store_activity foreign keys
ALTER TABLE `hopsworks`.`feature_store_activity`
    ADD COLUMN `feature_group_statistics_id` INT(11) NULL,
    ADD COLUMN `feature_view_statistics_id` INT(11) NULL,
    ADD COLUMN `training_dataset_statistics_id` INT(11) NULL,
    ADD CONSTRAINT `fs_act_fg_stat_fk` FOREIGN KEY (`feature_group_statistics_id`) REFERENCES `feature_group_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    ADD CONSTRAINT `fs_act_fv_stat_fk` FOREIGN KEY (`feature_view_statistics_id`) REFERENCES `feature_view_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    ADD CONSTRAINT `fs_act_td_stat_fk` FOREIGN KEY (`training_dataset_statistics_id`) REFERENCES `training_dataset_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
-- TODO: SQL Query populate ids based on statistics_id.
ALTER TABLE `hopsworks`.`feature_store_activity`
    DROP FOREIGN KEY `fs_act_stat_fk`,
    DROP COLUMN `statistics_id`;

ALTER TABLE `hopsworks`.`feature_store_statistic`
    DROP FOREIGN KEY `fg_fk_fss`,
    DROP FOREIGN KEY `fg_ci_fk_fss`,
    DROP FOREIGN KEY `td_fk_fss`,
    DROP FOREIGN KEY `inode_fk`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_statistic`;

CREATE TABLE IF NOT EXISTS `feature_group_descriptive_statistics` ( -- many-to-many relationship for legacy feature_group_statistics table
    `feature_group_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`feature_group_statistics_id`, `feature_descriptive_statistics_id`),
    KEY (`feature_descriptive_statistics_id`),
    CONSTRAINT `fgds_fgs_fk` FOREIGN KEY (`feature_group_statistics_id`) REFERENCES `feature_group_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fgds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_view_descriptive_statistics` ( -- many-to-many relationship for legacy feature_view_statistics table
    `feature_view_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`feature_view_statistics_id`, `feature_descriptive_statistics_id`),
    KEY (`feature_descriptive_statistics_id`),
    CONSTRAINT `fvds_fvs_fk` FOREIGN KEY (`feature_view_statistics_id`) REFERENCES `feature_view_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fvds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

-- training_dataset_descriptive_statistics serves as either training dataset statistics or train split statistics
CREATE TABLE IF NOT EXISTS `training_dataset_descriptive_statistics` ( -- many-to-many relationship for training_dataset_descriptive_statistics table
    `training_dataset_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`training_dataset_statistics_id`, `feature_descriptive_statistics_id`),
    KEY (`feature_descriptive_statistics_id`),
    CONSTRAINT `tdds_tds_fk` FOREIGN KEY (`training_dataset_statistics_id`) REFERENCES `training_dataset_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `tdds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `test_dataset_descriptive_statistics` ( -- many-to-many relationship for test_dataset_descriptive_statistics table
    `training_dataset_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`training_dataset_statistics_id`, `feature_descriptive_statistics_id`),
    KEY (`feature_descriptive_statistics_id`),
    CONSTRAINT `tsds_tds_fk` FOREIGN KEY (`training_dataset_statistics_id`) REFERENCES `training_dataset_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `tsds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `val_dataset_descriptive_statistics` ( -- many-to-many relationship for val_training_dataset_descriptive_statistics table
    `training_dataset_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`training_dataset_statistics_id`, `feature_descriptive_statistics_id`),
    KEY (`feature_descriptive_statistics_id`),
    CONSTRAINT `vlds_tds_fk` FOREIGN KEY (`training_dataset_statistics_id`) REFERENCES `training_dataset_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `vlds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_monitoring_result` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `feature_monitoring_config_id` INT(11) NOT NULL,
    `feature_name` VARCHAR(63) COLLATE latin1_general_cs NOT NULL,
    `execution_id` INT(11) NOT NULL,
    `monitoring_time` timestamp DEFAULT CURRENT_TIMESTAMP,
    `shift_detected` BOOLEAN DEFAULT FALSE,
    `detection_stats_id` INT(11),
    `reference_stats_id` INT(11),
    `difference` FLOAT DEFAULT NULL,
    `specific_value` FLOAT DEFAULT NULL,
    `empty_detection_window` BOOLEAN DEFAULT FALSE,
    `empty_reference_window` BOOLEAN DEFAULT FALSE,
    `raised_exception` BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (`id`),
    CONSTRAINT `config_monitoring_result_fk` FOREIGN KEY (`feature_monitoring_config_id`) REFERENCES `feature_monitoring_config` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `detection_stats_monitoring_result_fk` FOREIGN KEY (`detection_stats_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION,
    CONSTRAINT `reference_stats_monitoring_result_fk` FOREIGN KEY (`reference_stats_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopsworks`.`feature_view_alert` (
    `id` int AUTO_INCREMENT PRIMARY KEY,
    `status` varchar(45) NOT NULL,
    `type` varchar(45) NOT NULL,
    `severity` varchar(45) NOT NULL,
    `receiver` int NOT NULL,
    `created` timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `feature_view_id` int NOT NULL,
    CONSTRAINT `unique_feature_view_status` UNIQUE (`feature_view_id`, `status`),
    CONSTRAINT `fk_fv_alert_1` FOREIGN KEY (`receiver`) REFERENCES `hopsworks`.`alert_receiver` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_fv_alert_2` FOREIGN KEY (`feature_view_id`) REFERENCES `hopsworks`.`feature_view` (`id`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
