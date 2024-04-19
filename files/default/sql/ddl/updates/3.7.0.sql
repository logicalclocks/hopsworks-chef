-- FSTORE-1047
CREATE TABLE IF NOT EXISTS `hopsworks`.`embedding` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `feature_group_id` int(11) NOT NULL,
    `col_prefix` varchar(255) NULL,
    `vector_db_index_name` varchar(255) NOT NULL,
    PRIMARY KEY (`id`),
    KEY `feature_group_id` (`feature_group_id`),
    CONSTRAINT `feature_group_embedding_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
    ) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopsworks`.`embedding_feature` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `embedding_id` int(11) NOT NULL,
    `name` varchar(255) NOT NULL,
    `dimension` int NOT NULL,
    `similarity_function_type` varchar(255) NOT NULL,
    PRIMARY KEY (`id`),
    KEY `embedding_id` (`embedding_id`),
    CONSTRAINT `embedding_feature_fk` FOREIGN KEY (`embedding_id`) REFERENCES `embedding` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
    ) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopsworks`.`model` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `project_id` int(11) NOT NULL,
  UNIQUE KEY `project_unique_name` (`name`, `project_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `model_project_fk` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopsworks`.`model_version` (
  `model_id` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `description` VARCHAR(1000) DEFAULT NULL,
  `metrics` VARCHAR(3000) DEFAULT NULL,
  `program` VARCHAR(1000) DEFAULT NULL,
  `framework` VARCHAR(128) DEFAULT NULL,
  `environment` VARCHAR(1000) DEFAULT NULL,
  `experiment_id` VARCHAR(128) DEFAULT NULL,
  `experiment_project_name` VARCHAR(128) DEFAULT NULL,
  PRIMARY KEY (`model_id`, `version`),
  CONSTRAINT `user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `model_fk` FOREIGN KEY (`model_id`) REFERENCES `model` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- FSTORE-1146: Appending lots of features results in error to commit activity update
ALTER TABLE `hopsworks`.`feature_store_activity` MODIFY COLUMN `meta_msg` VARCHAR(15000) COLLATE latin1_general_cs DEFAULT NULL;

-- HWORKS-707: Store descriptive statistics in the DB instead of HopsFS
CREATE TABLE IF NOT EXISTS `hopsworks`.`feature_descriptive_statistics` (
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
    `min` DOUBLE,
    `max` DOUBLE,
    `sum` DOUBLE,
    `mean` DOUBLE,
    `stddev` DOUBLE,
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
CREATE TABLE IF NOT EXISTS `hopsworks`.`feature_group_statistics` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `computation_time` DATETIME(3) NOT NULL,
    `feature_group_id` INT(11) NOT NULL,
    `row_percentage` DECIMAL(6,5) NOT NULL DEFAULT 1.00, -- from -9.99999 to 9.99999 (3 bytes)
    -- fg statistics based on left fg commit times
    `window_start_commit_time` BIGINT(20) NOT NULL DEFAULT 0, -- window start commit time (fg). If computed on the whole fg data, it has value 0
    `window_end_commit_time` BIGINT(20) NOT NULL, -- commit time or window end commit time (fg). If non-time-travel-enabled, it has same value as computation time
    PRIMARY KEY (`id`),
    KEY `feature_group_id` (`feature_group_id`),
    UNIQUE KEY `window_commit_times_row_perc_fk` (`feature_group_id`, `window_start_commit_time`, `window_end_commit_time`, `row_percentage`),
    CONSTRAINT `fgs_fg_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopsworks`.`feature_group_descriptive_statistics` ( -- many-to-many relationship for legacy feature_group_statistics table
    `feature_group_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`feature_group_statistics_id`, `feature_descriptive_statistics_id`),
    CONSTRAINT `fgds_fgs_fk` FOREIGN KEY (`feature_group_statistics_id`) REFERENCES `feature_group_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fgds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

-- Create helper procedures to do batch operations on feature store statistics
DROP PROCEDURE IF EXISTS BatchProc;
DROP PROCEDURE IF EXISTS PopulateFeatureGroupStatistics;
DROP PROCEDURE IF EXISTS BatchPopulateFeatureGroupStatistics;
DROP PROCEDURE IF EXISTS PopulateFeatureDescriptiveStatistics;
DROP PROCEDURE IF EXISTS BatchPopulateFeatureDescriptiveStatistics;
DROP PROCEDURE IF EXISTS PopulateTrainingDatasetStatistics;
DROP PROCEDURE IF EXISTS BatchPopulateTrainingDatasetStatistics;
DROP PROCEDURE IF EXISTS PopulateFeatureDescriptiveStatisticsForTrainingDataset;
DROP PROCEDURE IF EXISTS BatchPopulateFeatureDescriptiveStatisticsForTrainingDataset;
DROP PROCEDURE IF EXISTS UpdateFeatureStoreActivity;
DROP PROCEDURE IF EXISTS BatchUpdateFeatureStoreActivity;
DROP PROCEDURE IF EXISTS UpdateFeatureStoreActivityForTrainingDatset;
DROP PROCEDURE IF EXISTS BatchUpdateFeatureStoreActivityForTrainingDatset;

DELIMITER //

-- Generic batch procedure to run batch jobs calls on the input procedure name
CREATE PROCEDURE BatchProc(proc_name VARCHAR(255), batch_size INT, start_id INT, end_id INT)
BEGIN
    DECLARE current_id INT;
    DECLARE done BOOLEAN DEFAULT FALSE;

    SET current_id = start_id;

    WHILE NOT done DO
        IF current_id + batch_size > end_id THEN
            SET batch_size = end_id - current_id + 1;
            SET done = TRUE;
        END IF;

        SELECT CONCAT('Processing batch from ', current_id, ' to ', current_id + batch_size - 1) AS log_message;

        SET @sql_stmt := CONCAT('CALL ', proc_name, '(', current_id, ',', current_id + batch_size - 1, ')');

        PREPARE stmt FROM @sql_stmt;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET current_id = current_id + batch_size;
    END WHILE;

    SELECT 'All batches processed' AS log_message;

END //

-- Procedure to populate feature_group_statistics
CREATE PROCEDURE PopulateFeatureGroupStatistics(start_id INT, end_id INT)
BEGIN
  -- -- insert new feature_group_statistics. For the same feature group commit statistics, only insert the last computed statistics. For non-time-travel feature groups, insert all computed statistics.
  INSERT INTO `hopsworks`.`feature_group_statistics` (id, computation_time, feature_group_id, window_end_commit_time)
  WITH sorted_feature_store_statistic AS (
    SELECT `hopsworks`.`feature_store_statistic`.*, ROW_NUMBER() OVER (PARTITION BY feature_group_id, IFNULL(feature_group_commit_id, UUID()) ORDER BY commit_time DESC) as rn
    FROM `hopsworks`.`feature_store_statistic` WHERE feature_group_id IS NOT NULL and feature_group_id BETWEEN start_id AND end_id
  )
  SELECT id, commit_time as computation_time, feature_group_id, IFNULL(feature_group_commit_id, UNIX_TIMESTAMP(commit_time)*1000) as window_end_commit_time
  FROM sorted_feature_store_statistic WHERE rn = 1; -- select last computed stats in the current fg stats batch --

END //

CREATE PROCEDURE BatchPopulateFeatureGroupStatistics()
BEGIN
    DECLARE start_id INT;
    DECLARE end_id INT;

    SELECT MIN(feature_group_id), MAX(feature_group_id) INTO start_id, end_id FROM `hopsworks`.`feature_store_statistic`;

    CALL BatchProc('PopulateFeatureGroupStatistics', 1000, start_id, end_id);

END //

-- Procedure to populate feature_descriptive_statistics
CREATE PROCEDURE PopulateFeatureDescriptiveStatistics(start_id INT, end_id INT)
BEGIN
  -- -- insert one feature descriptive statistic as a reference per feature_group_statistics. These will be used in the expat to parse and create the corresponding feature descriptive statistics rows
  INSERT INTO `hopsworks`.`feature_descriptive_statistics` (id, feature_name, feature_type, count, num_non_null_values, num_null_values, extended_statistics_path)
  SELECT id, 'for-migration', 'FEATURE_GROUP' as feature_type, feature_group_id, UNIX_TIMESTAMP(commit_time)*1000, feature_group_commit_id, file_path
  FROM `hopsworks`.`feature_store_statistic` WHERE id BETWEEN start_id AND end_id AND id IN (SELECT id FROM `hopsworks`.`feature_group_statistics`);

  -- -- insert one feature descriptive statistic per orphan feature group statistics file, to be deleted during the expat
  INSERT INTO `hopsworks`.`feature_descriptive_statistics` (id, feature_name, feature_type, count, extended_statistics_path)
  SELECT id, 'to-be-deleted', 'FEATURE_GROUP' as feature_type, feature_group_id, file_path
  FROM `hopsworks`.`feature_store_statistic` WHERE feature_group_id IS NOT NULL AND id BETWEEN start_id AND end_id AND id NOT IN (SELECT id FROM `hopsworks`.`feature_group_statistics`);
  -- To be done in the expat: insert feature_group_descriptive_statistics (many-to-many relationship), parse feature_descriptive_statistics, delete orphan fg statistics files
END //

CREATE PROCEDURE BatchPopulateFeatureDescriptiveStatistics()
BEGIN
    DECLARE start_id INT;
    DECLARE end_id INT;

    SELECT MIN(id), MAX(id) INTO start_id, end_id FROM `hopsworks`.`feature_store_statistic`;

    CALL BatchProc('PopulateFeatureDescriptiveStatistics', 1000, start_id, end_id);

END //

-- Procedure to populate training_dataset_statistics
CREATE PROCEDURE PopulateTrainingDatasetStatistics(start_id INT, end_id INT)
BEGIN
  -- -- insert new training_dataset_statistics. For the same training dataset, only insert the last computed statistics.
  INSERT INTO `hopsworks`.`training_dataset_statistics` (id, computation_time, training_dataset_id, before_transformation)
  WITH sorted_feature_store_statistic AS (
    SELECT `hopsworks`.`feature_store_statistic`.*, ROW_NUMBER() OVER (PARTITION BY training_dataset_id, for_transformation ORDER BY commit_time DESC) as rn -- group by td_id and before_transformation, and sort by commit_time --
    FROM `hopsworks`.`feature_store_statistic` WHERE training_dataset_id IS NOT NULL AND training_dataset_id BETWEEN start_id AND end_id
  )
  SELECT id, commit_time as computation_time, training_dataset_id, for_transformation
  FROM sorted_feature_store_statistic WHERE rn = 1; -- last computed stats --
END //

CREATE PROCEDURE BatchPopulateTrainingDatasetStatistics()
BEGIN
    DECLARE start_id INT;
    DECLARE end_id INT;

    SELECT MIN(training_dataset_id), MAX(training_dataset_id) INTO start_id, end_id FROM `hopsworks`.`feature_store_statistic`;

    CALL BatchProc('PopulateTrainingDatasetStatistics', 1000, start_id, end_id);

END //

-- Procedure to populate feature_descriptive_statistics
CREATE PROCEDURE PopulateFeatureDescriptiveStatisticsForTrainingDataset(start_id INT, end_id INT)
BEGIN
    -- -- insert one feature descriptive statistic as a reference per training dataset statistics. These will be used in the expat to parse and create the corresponding feature descriptive statistics rows
    INSERT INTO `hopsworks`.`feature_descriptive_statistics` (id, feature_name, feature_type, count, num_non_null_values, num_null_values, extended_statistics_path)
    SELECT id, 'for-migration', 'TRAINING_DATASET' as feature_type, training_dataset_id, UNIX_TIMESTAMP(commit_time)*1000, feature_group_commit_id, file_path
    FROM `hopsworks`.`feature_store_statistic` WHERE id BETWEEN start_id AND end_id AND id IN (SELECT id FROM training_dataset_statistics);
    -- -- insert one feature descriptive statistic per orphan training dataset statistics file, to be deleted during the expat
    INSERT INTO `hopsworks`.`feature_descriptive_statistics` (id, feature_name, feature_type, count, extended_statistics_path)
    SELECT id, 'to-be-deleted', 'TRAINING_DATASET' as feature_type, training_dataset_id, file_path
    FROM `hopsworks`.`feature_store_statistic` WHERE training_dataset_id IS NOT NULL AND id BETWEEN start_id AND end_id AND id NOT IN (SELECT id FROM `hopsworks`.`training_dataset_statistics`);
    -- To be done in the expat: insert training_dataset_descriptive_statistics, test_dataset_descriptive_statistics, val_dataset_descriptive_statistics (many-to-many relationship), parse feature_descriptive_statistics
    -- and delete orphan statistics files. Split statistics are handled in the expat migration as well
END //

CREATE PROCEDURE BatchPopulateFeatureDescriptiveStatisticsForTrainingDataset()
BEGIN
    DECLARE start_id INT;
    DECLARE end_id INT;

    SELECT MIN(id), MAX(id) INTO start_id, end_id FROM `hopsworks`.`feature_store_statistic`;

    CALL BatchProc('PopulateFeatureDescriptiveStatisticsForTrainingDataset', 1000, start_id, end_id);

END //

-- Procedure to update feature_store_activity
CREATE PROCEDURE UpdateFeatureStoreActivity(start_id INT, end_id INT)
BEGIN
    UPDATE `hopsworks`.`feature_store_activity` SET feature_group_statistics_id = statistics_id
    WHERE statistics_id IS NOT NULL AND feature_group_id IS NOT NULL AND feature_group_id BETWEEN start_id AND end_id AND EXISTS(SELECT 1 FROM `hopsworks`.`feature_group_statistics` WHERE id = statistics_id LIMIT 1);

    DELETE FROM `hopsworks`.`feature_store_activity` WHERE statistics_id IS NOT NULL AND feature_group_id IS NOT NULL AND feature_group_id BETWEEN start_id AND end_id AND feature_group_statistics_id IS NULL;
END //

CREATE PROCEDURE BatchUpdateFeatureStoreActivity()
BEGIN
    DECLARE start_id INT;
    DECLARE end_id INT;

    SELECT MIN(feature_group_id), MAX(feature_group_id) INTO start_id, end_id FROM `hopsworks`.`feature_store_activity`;

    CALL BatchProc('UpdateFeatureStoreActivity', 1000, start_id, end_id);

END //

-- Procedure to update feature_store_activity
CREATE PROCEDURE UpdateFeatureStoreActivityForTrainingDatset(start_id INT, end_id INT)
BEGIN
    UPDATE `hopsworks`.`feature_store_activity` SET training_dataset_statistics_id = statistics_id
        WHERE statistics_id IS NOT NULL AND training_dataset_id IS NOT NULL AND training_dataset_id BETWEEN start_id AND end_id AND EXISTS(SELECT 1 FROM `hopsworks`.`training_dataset_statistics` WHERE id = statistics_id LIMIT 1);

    DELETE FROM `hopsworks`.`feature_store_activity` WHERE statistics_id IS NOT NULL AND training_dataset_id IS NOT NULL AND training_dataset_id BETWEEN start_id AND end_id AND training_dataset_statistics_id IS NULL;
END //

CREATE PROCEDURE BatchUpdateFeatureStoreActivityForTrainingDatset()
BEGIN
    DECLARE start_id INT;
    DECLARE end_id INT;

    SELECT MIN(training_dataset_id), MAX(training_dataset_id) INTO start_id, end_id FROM `hopsworks`.`feature_store_activity`;

    CALL BatchProc('UpdateFeatureStoreActivityForTrainingDatset', 1000, start_id, end_id);

END //

DELIMITER ;


SET SQL_SAFE_UPDATES = 0;
CALL BatchPopulateFeatureGroupStatistics();
CALL BatchPopulateFeatureDescriptiveStatistics();
SET SQL_SAFE_UPDATES = 1;

-- -- training dataset statistics
CREATE TABLE IF NOT EXISTS `hopsworks`.`training_dataset_statistics` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `computation_time` DATETIME(3) NOT NULL,
    `training_dataset_id`INT(11) NOT NULL,
    `before_transformation` TINYINT(1) DEFAULT '0',
    `row_percentage` DECIMAL(6,5) NOT NULL DEFAULT 1.00, -- from -9.99999 to 9.99999 (3 bytes)
    PRIMARY KEY (`id`),
    KEY `training_dataset_id` (`training_dataset_id`),
    UNIQUE KEY `tr_ids_before_trans_row_perc_fk` (`training_dataset_id`, `before_transformation`, `row_percentage`),
    CONSTRAINT `tds_td_fk` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

SET SQL_SAFE_UPDATES = 0;
CALL BatchPopulateTrainingDatasetStatistics();
CALL BatchPopulateFeatureDescriptiveStatisticsForTrainingDataset();
SET SQL_SAFE_UPDATES = 1;

-- -- Update feature_store_activity foreign keys
ALTER TABLE `hopsworks`.`feature_store_activity`
    ADD COLUMN `feature_group_statistics_id` INT(11) NULL,
    ADD COLUMN `training_dataset_statistics_id` INT(11) NULL;

ALTER TABLE `hopsworks`.`feature_store_activity`
    ADD CONSTRAINT `fs_act_fg_stat_fk` FOREIGN KEY (`feature_group_statistics_id`) REFERENCES `feature_group_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    ADD CONSTRAINT `fs_act_td_stat_fk` FOREIGN KEY (`training_dataset_statistics_id`) REFERENCES `training_dataset_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    DROP FOREIGN KEY `fs_act_stat_fk`;

SET SQL_SAFE_UPDATES = 0;
-- -- update feature_store_activity statistics ids
CALL BatchUpdateFeatureStoreActivity();
CALL BatchUpdateFeatureStoreActivityForTrainingDatset();
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`feature_store_activity`
    DROP COLUMN `statistics_id`;

ALTER TABLE `hopsworks`.`feature_store_statistic`
    DROP FOREIGN KEY `fg_fk_fss`,
    DROP FOREIGN KEY `td_fk_fss`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_statistic`;

-- training_dataset_descriptive_statistics serves as either training dataset statistics or train split statistics
CREATE TABLE IF NOT EXISTS `hopsworks`.`training_dataset_descriptive_statistics` ( -- many-to-many relationship for training_dataset_descriptive_statistics table
    `training_dataset_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`training_dataset_statistics_id`, `feature_descriptive_statistics_id`),
    CONSTRAINT `tdds_tds_fk` FOREIGN KEY (`training_dataset_statistics_id`) REFERENCES `training_dataset_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `tdds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopsworks`.`test_dataset_descriptive_statistics` ( -- many-to-many relationship for test_dataset_descriptive_statistics table
    `training_dataset_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`training_dataset_statistics_id`, `feature_descriptive_statistics_id`),
    CONSTRAINT `tsds_tds_fk` FOREIGN KEY (`training_dataset_statistics_id`) REFERENCES `training_dataset_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `tsds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopsworks`.`val_dataset_descriptive_statistics` ( -- many-to-many relationship for val_dataset_descriptive_statistics table
    `training_dataset_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`training_dataset_statistics_id`, `feature_descriptive_statistics_id`),
    CONSTRAINT `vlds_tds_fk` FOREIGN KEY (`training_dataset_statistics_id`) REFERENCES `training_dataset_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `vlds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

-- HWORKS-919
ALTER TABLE `hopsworks`.`project` ADD COLUMN `online_feature_store_available` tinyint(1) NOT NULL DEFAULT '1';

-- FSTORE-1147
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `notification_topic_name` VARCHAR(255) DEFAULT NULL;

-- Feature monitoring
CREATE TABLE IF NOT EXISTS `hopsworks`.`monitoring_window_config` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `window_config_type` INT(11) NOT NULL,
    `training_dataset_version` INT(11),
    `time_offset` VARCHAR(63),
    `window_length` VARCHAR(63),
    `row_percentage` DECIMAL(15,2),
    `specific_value` FLOAT,
    PRIMARY KEY (`id`)
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopsworks`.`statistics_comparison_config` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `strict` BOOLEAN DEFAULT FALSE,
    `relative` BOOLEAN DEFAULT FALSE,
    `threshold` FLOAT,
    `metric` INT(11) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopsworks`.`feature_monitoring_config` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `feature_group_id` INT(11),
    `feature_view_id` INT(11),
    `name` VARCHAR(63) COLLATE latin1_general_cs NOT NULL,
    `description` VARCHAR(2000) COLLATE latin1_general_cs DEFAULT NULL,
    `feature_name` VARCHAR(63) COLLATE latin1_general_cs DEFAULT NULL,
    `feature_monitoring_type` tinyint(4) NOT NULL,
    `job_id` INT(11) NOT NULL,
    `job_schedule_id` INT(11),
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
    CONSTRAINT `job_schedule_fk` FOREIGN KEY (`job_schedule_id`) REFERENCES `job_schedule` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopsworks`.`feature_monitoring_result` (
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

-- -- feature view statistics
CREATE TABLE IF NOT EXISTS `hopsworks`.`feature_view_statistics` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `computation_time` DATETIME(3) NOT NULL,
    `feature_view_id`INT(11) NOT NULL,
    `row_percentage` DECIMAL(15,2) NOT NULL DEFAULT 1.00,
    -- fv statistics based on left fg commit times
    `window_start_commit_time` BIGINT(20) NOT NULL DEFAULT 0, -- window start commit time (fg). If computed on the whole fg data, it has value 0
    `window_end_commit_time` BIGINT(20) NOT NULL, -- commit time or window end commit time (fg). If non-time-travel-enabled, it has same value as computation time
    PRIMARY KEY (`id`),
    KEY `feature_view_id` (`feature_view_id`),
    UNIQUE KEY `window_commit_times_row_perc_fk` (`feature_view_id`, `window_start_commit_time`, `window_end_commit_time`, `row_percentage`),
    CONSTRAINT `fvs_fv_fk` FOREIGN KEY (`feature_view_id`) REFERENCES `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopsworks`.`feature_view_descriptive_statistics` ( -- many-to-many relationship for legacy feature_view_statistics table
    `feature_view_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`feature_view_statistics_id`, `feature_descriptive_statistics_id`),
    CONSTRAINT `fvds_fvs_fk` FOREIGN KEY (`feature_view_statistics_id`) REFERENCES `feature_view_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fvds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

-- -- Update feature_store_activity foreign keys
ALTER TABLE `hopsworks`.`feature_store_activity`
    ADD COLUMN `feature_view_statistics_id` INT(11) NULL;

ALTER TABLE `hopsworks`.`feature_store_activity` ADD CONSTRAINT `fs_act_fv_stat_fk` FOREIGN KEY (`feature_view_statistics_id`) REFERENCES `feature_view_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
