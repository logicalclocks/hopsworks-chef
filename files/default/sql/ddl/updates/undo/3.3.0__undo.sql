
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
-- alert feature monitoring changes
DROP TABLE IF EXISTS `hopsworks`.`feature_view_alert`;
-- end of alert for FM
