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
    `training_dataset_id` INT(11),
    `time_offset` VARCHAR(63),
    `window_length` VARCHAR(63),
    `row_percentage` FLOAT,
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
    `feature_type` varchar(20) NOT NULL,
    `feature_name` VARCHAR(63) COLLATE latin1_general_cs NOT NULL,
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
    `row_percentage` FLOAT NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_monitoring_result` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `feature_monitoring_config_id` INT(11) NOT NULL,
    `feature_name` VARCHAR(63) COLLATE latin1_general_cs NOT NULL,
    `execution_id` INT(11) NOT NULL,
    `monitoring_time` timestamp DEFAULT CURRENT_TIMESTAMP,
    `shift_detected` BOOLEAN DEFAULT FALSE,
    `detection_stats_id` INT(11) NOT NULL,
    `reference_stats_id` INT(11),
    `difference` FLOAT,
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