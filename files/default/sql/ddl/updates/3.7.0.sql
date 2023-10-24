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
    `row_percentage` DECIMAL(15,2) NOT NULL DEFAULT 1.00,
    -- fg statistics based on left fg commit times
    `window_start_commit_id` BIGINT(20) DEFAULT NULL, -- window start commit id (fg)
    `window_end_commit_id` BIGINT(20) DEFAULT NULL, -- commit id or window end commit id (fg)
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
    -- we cannot reuse start and end time columns because for event times we need the stastistics commit time as part of the unique key
    -- for commit time windows, statistics are unique. However, for event time windows there can be multiple statisics computed over time on that specific event time window.
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
    DROP FOREIGN KEY `td_fk_fss`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_statistic`;

CREATE TABLE IF NOT EXISTS `feature_view_descriptive_statistics` ( -- many-to-many relationship for legacy feature_view_statistics table
    `feature_view_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`feature_view_statistics_id`, `feature_descriptive_statistics_id`),
    CONSTRAINT `fvds_fvs_fk` FOREIGN KEY (`feature_view_statistics_id`) REFERENCES `feature_view_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fvds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

-- training_dataset_descriptive_statistics serves as either training dataset statistics or train split statistics
CREATE TABLE IF NOT EXISTS `training_dataset_descriptive_statistics` ( -- many-to-many relationship for training_dataset_descriptive_statistics table
    `training_dataset_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`training_dataset_statistics_id`, `feature_descriptive_statistics_id`),
    CONSTRAINT `tdds_tds_fk` FOREIGN KEY (`training_dataset_statistics_id`) REFERENCES `training_dataset_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `tdds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `test_dataset_descriptive_statistics` ( -- many-to-many relationship for test_dataset_descriptive_statistics table
    `training_dataset_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`training_dataset_statistics_id`, `feature_descriptive_statistics_id`),
    CONSTRAINT `tsds_tds_fk` FOREIGN KEY (`training_dataset_statistics_id`) REFERENCES `training_dataset_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `tsds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `val_dataset_descriptive_statistics` ( -- many-to-many relationship for val_training_dataset_descriptive_statistics table
    `training_dataset_statistics_id` int(11) NOT NULL,
    `feature_descriptive_statistics_id` int(11) NOT NULL,
    PRIMARY KEY (`training_dataset_statistics_id`, `feature_descriptive_statistics_id`),
    CONSTRAINT `vlds_tds_fk` FOREIGN KEY (`training_dataset_statistics_id`) REFERENCES `training_dataset_statistics` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `vlds_fds_fk` FOREIGN KEY (`feature_descriptive_statistics_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;
