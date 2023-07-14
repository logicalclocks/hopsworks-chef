-- FSTORE-928: When hitting limit of number of projects that one user can create, deleting a project doesn't work as expected
ALTER TABLE `hopsworks`.`users` DROP COLUMN `num_created_projects`;

-- FSTORE-921
CREATE TABLE `serving_key` (
                               `id` int(11) NOT NULL AUTO_INCREMENT,
                               `prefix` VARCHAR(63) NULL DEFAULT '',
                               `feature_name` VARCHAR(1000) NOT NULL,
                               `join_on` VARCHAR(1000) NULL,
                               `join_index` int(11) NOT NULL,
                               `feature_group_id` INT(11) NOT NULL,
                               `required` tinyint(1) NOT NULL DEFAULT '0',
                               `feature_view_id` INT(11) NULL,
                               PRIMARY KEY (`id`),
                               KEY `feature_view_id` (`feature_view_id`),
                               KEY `feature_group_id` (`feature_group_id`),
                               CONSTRAINT `feature_view_serving_key_fk` FOREIGN KEY (`feature_view_id`) REFERENCES `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
                               CONSTRAINT `feature_group_serving_key_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- HWORKS-351: Add support to run generic docker commands
ALTER TABLE `hopsworks`.`conda_commands` MODIFY COLUMN `arg` VARCHAR(11000) DEFAULT NULL;
ALTER TABLE `hopsworks`.`conda_commands` ADD COLUMN `custom_commands_file` VARCHAR(255) DEFAULT NULL;

-- Feature monitoring 
CREATE TABLE IF NOT EXISTS `monitoring_window_config` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `window_config_type` INT(11) NOT NULL,
    `training_dataset_version` INT(11),
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
    `start_date_time` timestamp NOT NULL,
    `end_date_time` timestamp,
    `enabled` BOOLEAN NOT NULL,
    `cron_expression` varchar(500) NOT NULL,
    `next_execution_date_time` timestamp,
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
    `transformed_with_version` INT(11) DEFAULT NULL,
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
    `feature_type` VARCHAR(20),
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

-- -- feature group statistics
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

CREATE TABLE IF NOT EXISTS `feature_group_descriptive_statistics` ( -- many-to-many relationship for legacy feature_group_statistics table
    `feature_group_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`feature_group_statistics_id`, `feature_descriptive_statistics_id`),
    KEY (`feature_descriptive_statistics_id`),
    CONSTRAINT `fgds_fgs_fk` FOREIGN KEY (`feature_group_statistics_id`) REFERENCES `feature_group_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fgds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

SET SQL_SAFE_UPDATES = 0;
-- -- insert new feature_group_statistics. For the same feature group commit statistics, only insert the last computed statistics. For non-time-travel feature groups, insert all computed statistics.
INSERT INTO `feature_group_statistics` (id, commit_time, feature_group_id, window_end_commit_id)
  SELECT MAX(id) as id, MAX(commit_time) as commit_time, feature_group_id, MAX(feature_group_commit_id) as feature_group_commit_id FROM `feature_store_statistic`
  WHERE feature_group_id IS NOT NULL GROUP BY feature_group_id, IFNULL(feature_group_commit_id, UUID());
-- -- insert one feature descriptive statistic as a reference per feature_group_statistics. These will be used in the expat to parse and create the corresponding feature descriptive statistics rows
INSERT INTO `feature_descriptive_statistics` (id, feature_name, feature_type, count, num_non_null_values, num_null_values, extended_statistics_path)
  SELECT id, 'for-migration', 'FEATURE_GROUP' as feature_type, feature_group_id, UNIX_TIMESTAMP(commit_time)*1000, feature_group_commit_id, file_path
  FROM `feature_store_statistic` WHERE id IN (SELECT id FROM `feature_group_statistics`);
-- -- insert one feature descriptive statistic per orphan feature group statistics file, to be deleted during the expat
INSERT INTO `feature_descriptive_statistics` (id, feature_name, feature_type, count, extended_statistics_path)
  SELECT id, 'to-be-deleted', 'FEATURE_GROUP' as feature_type, feature_group_id, file_path
  FROM `feature_store_statistic` WHERE feature_group_id IS NOT NULL AND id NOT IN (SELECT id FROM `feature_group_statistics`);
-- To be done in the expat: insert feature_group_descriptive_statistics (many-to-many relationship), parse feature_descriptive_statistics, delete orphan fg statistics files
SET SQL_SAFE_UPDATES = 1;

-- -- feature view statistics

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

-- -- training dataset statistics

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

SET SQL_SAFE_UPDATES = 0;
-- -- insert new training_dataset_statistics. For the same training dataset, only insert the last computed statistics.
INSERT INTO `training_dataset_statistics` (id, commit_time, training_dataset_id, for_transformation)
  SELECT MAX(id) as id, MAX(commit_time) as commit_time, training_dataset_id, for_transformation FROM `feature_store_statistic`
  WHERE training_dataset_id IS NOT NULL GROUP BY training_dataset_id, for_transformation;
-- -- insert one feature descriptive statistic as a reference per training dataset statistics. These will be used in the expat to parse and create the corresponding feature descriptive statistics rows
INSERT INTO `feature_descriptive_statistics` (id, feature_name, feature_type, count, num_non_null_values, num_null_values, extended_statistics_path)
  SELECT id, 'for-migration', 'TRAINING_DATASET' as feature_type, training_dataset_id, UNIX_TIMESTAMP(commit_time)*1000, feature_group_commit_id, file_path
  FROM `feature_store_statistic` WHERE id IN (SELECT id FROM training_dataset_statistics);
  -- -- insert one feature descriptive statistic per orphan training dataset statistics file, to be deleted during the expat
INSERT INTO `feature_descriptive_statistics` (id, feature_name, feature_type, count, extended_statistics_path)
  SELECT id, 'to-be-deleted', 'TRAINING_DATASET' as feature_type, training_dataset_id, file_path
  FROM `feature_store_statistic` WHERE training_dataset_id IS NOT NULL AND id NOT IN (SELECT id FROM `training_dataset_statistics`);
-- To be done in the expat: insert training_dataset_descriptive_statistics, test_dataset_descriptive_statistics, val_dataset_descriptive_statistics (many-to-many relationship), parse feature_descriptive_statistics
-- and delete orphan statistics files. Split statistics are handled in the expat migration as well
SET SQL_SAFE_UPDATES = 1;   

-- -- Update feature_store_activity foreign keys
ALTER TABLE `hopsworks`.`feature_store_activity`
    ADD COLUMN `feature_group_statistics_id` INT(11) NULL,
    ADD COLUMN `feature_view_statistics_id` INT(11) NULL,
    ADD COLUMN `training_dataset_statistics_id` INT(11) NULL;

ALTER TABLE `hopsworks`.`feature_store_activity`
    ADD CONSTRAINT `fs_act_fg_stat_fk` FOREIGN KEY (`feature_group_statistics_id`) REFERENCES `feature_group_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    ADD CONSTRAINT `fs_act_fv_stat_fk` FOREIGN KEY (`feature_view_statistics_id`) REFERENCES `feature_view_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    ADD CONSTRAINT `fs_act_td_stat_fk` FOREIGN KEY (`training_dataset_statistics_id`) REFERENCES `training_dataset_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    DROP FOREIGN KEY `fs_act_stat_fk`;

SET SQL_SAFE_UPDATES = 0;
-- -- update feature_store_activity statistics ids
UPDATE `feature_store_activity` SET feature_group_statistics_id = statistics_id WHERE statistics_id IS NOT NULL AND feature_group_id IS NOT NULL;
UPDATE `feature_store_activity` SET training_dataset_statistics_id = statistics_id WHERE statistics_id IS NOT NULL AND training_dataset_id IS NOT NULL;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`feature_store_activity`
    DROP COLUMN `statistics_id`;

ALTER TABLE `hopsworks`.`feature_store_statistic`
    DROP FOREIGN KEY `fg_fk_fss`,
    DROP FOREIGN KEY `fg_ci_fk_fss`,
    DROP FOREIGN KEY `td_fk_fss`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_statistic`;

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