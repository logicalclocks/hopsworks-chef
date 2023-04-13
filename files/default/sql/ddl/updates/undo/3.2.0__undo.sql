ALTER TABLE `hopsworks`.`project` ADD COLUMN `retention_period` date DEFAULT NULL,
  ADD COLUMN `archived` tinyint(1) DEFAULT '0',
  ADD COLUMN `logs` tinyint(1) DEFAULT '0',
  ADD COLUMN `deleted` tinyint(1) DEFAULT '0';

DROP TABLE IF EXISTS `hopsworks`.`hdfs_command_execution`;

ALTER TABLE `hopsworks`.`executions` MODIFY COLUMN `app_id` char(30) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`maggy_driver` MODIFY COLUMN `app_id` char(30) COLLATE latin1_general_cs NOT NULL;

--
-- Table structure for table `shared_topics`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shared_topics` (
                                 `topic_name` varchar(255) COLLATE latin1_general_cs NOT NULL,
                                 `project_id` int(11) NOT NULL,
                                 `owner_id` int(11) NOT NULL,
                                 `accepted` tinyint(1) NOT NULL DEFAULT '0',
                                 PRIMARY KEY (`project_id`,`topic_name`),
                                 KEY `topic_idx` (`topic_name`,`owner_id`),
                                 CONSTRAINT `topic_idx_shared` FOREIGN KEY (`topic_name`,`owner_id`) REFERENCES `project_topics` (`topic_name`,`project_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs
    /*!50100 PARTITION BY KEY (topic_name) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_acls`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `topic_acls` (
                              `id` int(11) NOT NULL AUTO_INCREMENT,
                              `topic_name` varchar(255) COLLATE latin1_general_cs NOT NULL,
                              `project_id` int(11) NOT NULL,
                              `username` varchar(150) COLLATE latin1_general_cs NOT NULL,
                              `principal` varchar(170) COLLATE latin1_general_cs NOT NULL,
                              `permission_type` varchar(255) COLLATE latin1_general_cs NOT NULL,
                              `operation_type` varchar(255) COLLATE latin1_general_cs NOT NULL,
                              `host` varchar(255) COLLATE latin1_general_cs NOT NULL,
                              `role` varchar(255) COLLATE latin1_general_cs NOT NULL,
                              PRIMARY KEY (`id`),
                              KEY `username` (`username`),
                              KEY `topic_idx` (`topic_name`,`project_id`),
                              CONSTRAINT `FK_262_338` FOREIGN KEY (`username`) REFERENCES `users` (`email`) ON DELETE NO ACTION ON UPDATE NO ACTION,
                              CONSTRAINT `topic_idx_topic_acls` FOREIGN KEY (`topic_name`,`project_id`) REFERENCES `project_topics` (`topic_name`,`project_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

ALTER TABLE `hopsworks`.`project_topics` DROP INDEX `topic_name_UNIQUE`;

SET SQL_SAFE_UPDATES = 0;
UPDATE `project_team`
SET team_role = 'Data scientist'
WHERE team_member = 'serving@hopsworks.se';
SET SQL_SAFE_UPDATES = 1;

DROP TABLE IF EXISTS `hopsworks`.`feature_monitoring_result`;

-- Re-create old statistics table
CREATE TABLE `feature_store_statistic` (
                                           `id` int(11) NOT NULL AUTO_INCREMENT,
                                           `commit_time` DATETIME(3) NOT NULL,
                                           `inode_pid` BIGINT(20) NOT NULL,
                                           `inode_name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL,
                                           `partition_id` BIGINT(20) NOT NULL,
                                           `feature_group_id` INT(11),
                                           `feature_group_commit_id` BIGINT(20),
                                           `training_dataset_id`INT(11),
                                           `for_transformation` TINYINT(1) DEFAULT '0',
                                           PRIMARY KEY (`id`),
                                           KEY `feature_group_id` (`feature_group_id`),
                                           KEY `training_dataset_id` (`training_dataset_id`),
                                           KEY `feature_group_commit_id_fk` (`feature_group_id`, `feature_group_commit_id`),
                                           CONSTRAINT `fg_fk_fss` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
                                           CONSTRAINT `fg_ci_fk_fss` FOREIGN KEY (`feature_group_id`, `feature_group_commit_id`) REFERENCES `feature_group_commit` (`feature_group_id`, `commit_id`) ON DELETE SET NULL ON UPDATE NO ACTION,
                                           CONSTRAINT `td_fk_fss` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
                                           CONSTRAINT `inode_fk` FOREIGN KEY (`inode_pid`,`inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
-- TODO: SQL Queries re-populate feature_store_statistic table

-- Update feature_store_activity foreign keys
ALTER TABLE `hopsworks`.`feature_store_activity`
    ADD COLUMN `statistics_id` INT(11) NULL,
    ADD CONSTRAINT `fs_act_stat_fk` FOREIGN KEY (`statistics_id`) REFERENCES `feature_store_statistic` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
-- TODO: SQL Query populate statistics_id based on the other fk
ALTER TABLE `hopsworks`.`feature_store_activity`
    DROP COLUMN `feature_group_statistics_id`,
    DROP FOREIGN KEY `fs_act_fg_stat_fk`,
    DROP COLUMN `feature_view_statistics_id`,
    DROP FOREIGN KEY `fs_act_fv_stat_fk`,
    DROP COLUMN `training_dataset_statistics_id`,
    DROP FOREIGN KEY `fs_act_td_stat_fk`;

-- Delete many-to-many intermediate tables
DROP TABLE IF EXISTS `hopsworks`.`feature_group_descriptive_statistics`;
DROP TABLE IF EXISTS `hopsworks`.`feature_view_descriptive_statistics`;
DROP TABLE IF EXISTS `hopsworks`.`training_dataset_descriptive_statistics`;

-- Delete new statistics tables
ALTER TABLE `hopsworks`.`feature_group_statistics`
  -- DROP KEY `feature_group_id`,
  -- DROP KEY `window_start_commit_id_fk`,
  -- DROP KEY `window_end_commit_id_fk`,
  DROP FOREIGN KEY `fgs_fg_fk`,
  DROP FOREIGN KEY `fgs_wec_fk`,
  DROP FOREIGN KEY `fgs_wsc_fk`,
  DROP FOREIGN KEY `fgs_inode_fk`;
DROP TABLE IF EXISTS `hopsworks`.`feature_group_statistics`;

ALTER TABLE `hopsworks`.`feature_view_statistics`,
  -- DROP KEY `feature_view_id`,
  -- DROP KEY `window_start_event_time`,
  -- DROP KEY `window_end_event_time`,
  DROP FOREIGN KEY `fvs_fv_fk`,
  DROP FOREIGN KEY `fvs_inode_fk`;
DROP TABLE IF EXISTS `hopsworks`.`feature_view_statistics`;

ALTER TABLE `hopsworks`.`training_dataset_statistics`
  -- DROP KEY `training_dataset_id`,
  DROP FOREIGN KEY `tds_td_fk`,
  DROP FOREIGN KEY `tds_inode_fk`;
DROP TABLE IF EXISTS `hopsworks`.`training_dataset_statistics`;

DROP TABLE IF EXISTS `hopsworks`.`feature_descriptive_statistics`;
DROP TABLE IF EXISTS `hopsworks`.`feature_monitoring_config`;
DROP TABLE IF EXISTS `hopsworks`.`monitoring_window_config`;
DROP TABLE IF EXISTS `hopsworks`.`statistics_comparison_config`;

DROP TABLE IF EXISTS `hopsworks`.`job_schedule`;
