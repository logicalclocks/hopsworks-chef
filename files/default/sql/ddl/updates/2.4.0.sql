CREATE TABLE IF NOT EXISTS `feature_store_code` (
                                                    `id` int(11) NOT NULL AUTO_INCREMENT,
                                                    `commit_time` DATETIME(3) NOT NULL,
                                                    `inode_pid` BIGINT(20) NOT NULL,
                                                    `inode_name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL,
                                                    `partition_id` BIGINT(20) NOT NULL,
                                                    `feature_group_id` INT(11),
                                                    `feature_group_commit_id` BIGINT(20),
                                                    `training_dataset_id`INT(11),
                                                    `application_id`VARCHAR(50),
                                                    PRIMARY KEY (`id`),
                                                    KEY `feature_group_id` (`feature_group_id`),
                                                    KEY `training_dataset_id` (`training_dataset_id`),
                                                    KEY `feature_group_commit_id_fk` (`feature_group_id`, `feature_group_commit_id`),
                                                    CONSTRAINT `fg_fk_fsc` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
                                                    CONSTRAINT `fg_ci_fk_fsc` FOREIGN KEY (`feature_group_id`, `feature_group_commit_id`) REFERENCES `feature_group_commit` (`feature_group_id`, `commit_id`) ON DELETE SET NULL ON UPDATE NO ACTION,
                                                    CONSTRAINT `td_fk_fsc` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
                                                    CONSTRAINT `inode_fk_fsc` FOREIGN KEY (`inode_pid`,`inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`on_demand_feature` ADD COLUMN `idx` int(11) NOT NULL DEFAULT 0;

ALTER TABLE `hopsworks`.`statistics_config`
    ADD COLUMN `exact_uniqueness` TINYINT(1) NOT NULL DEFAULT '1';

DROP TABLE `hopsworks`.`ndb_backup`;

DROP TABLE `project_devices`;
DROP TABLE `project_devices_settings`;

ALTER TABLE `hopsworks`.`dataset_shared_with` ADD COLUMN `shared_by` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`dataset_shared_with` ADD COLUMN `accepted_by` INT(11) DEFAULT NULL;

ALTER TABLE `hopsworks`.`dataset_shared_with` ADD CONSTRAINT `fk_shared_by` FOREIGN KEY (`shared_by`) REFERENCES `users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`dataset_shared_with` ADD CONSTRAINT `fk_accepted_by` FOREIGN KEY (`accepted_by`) REFERENCES `users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`feature_store_snowflake_connector` ADD COLUMN `application` VARCHAR(50) DEFAULT NULL;

CREATE TABLE IF NOT EXISTS `hopsworks`.`alert_receiver` (
                                                            `id` INT(11) NOT NULL AUTO_INCREMENT,
                                                            `name` VARCHAR(128) NOT NULL,
                                                            `config` BLOB NOT NULL,
                                                            PRIMARY KEY (`id`),
                                                            UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`project_service_alert` ADD COLUMN `receiver` INT(11) DEFAULT NULL,
                                                ADD INDEX `fk_project_service_alert_1_idx` (`receiver`);

ALTER TABLE `hopsworks`.`project_service_alert`
    ADD CONSTRAINT `fk_project_service_alert_1` FOREIGN KEY (`receiver`)
        REFERENCES `hopsworks`.`alert_receiver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`job_alert` ADD COLUMN `receiver` INT(11) DEFAULT NULL,
                                    ADD INDEX `fk_job_alert_1_idx` (`receiver`);

ALTER TABLE `hopsworks`.`job_alert`
    ADD CONSTRAINT `fk_job_alert_1` FOREIGN KEY (`receiver`)
        REFERENCES `hopsworks`.`alert_receiver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`feature_group_alert` ADD COLUMN `receiver` INT(11) DEFAULT NULL,
                                              ADD INDEX `fk_feature_group_alert_1_idx` (`receiver` ASC);

ALTER TABLE `hopsworks`.`feature_group_alert`
    ADD CONSTRAINT `fk_feature_group_alert_1` FOREIGN KEY (`receiver`)
        REFERENCES `hopsworks`.`alert_receiver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`jupyter_project` ADD COLUMN `no_limit` tinyint(1) DEFAULT 0;

ALTER TABLE `hopsworks`.`jupyter_settings` ADD COLUMN `no_limit` tinyint(1) DEFAULT 0;

ALTER TABLE `hopsworks`.`oauth_login_state` MODIFY COLUMN `state` VARCHAR(256);

ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `event_time` VARCHAR(63) DEFAULT NULL;
