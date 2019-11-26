ALTER TABLE `hopsworks`.`jobs` CHANGE COLUMN `json_config` `json_config` VARCHAR(12500) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`jupyter_settings` CHANGE COLUMN `json_config` `job_config` VARCHAR(11000) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`message` CHANGE COLUMN `content` `content` VARCHAR(11000) COLLATE latin1_general_cs NOT NULL;

CREATE TABLE IF NOT EXISTS `hopsworks`.`dataset_shared_with` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dataset` int(11) NOT NULL,
  `project` int(11) NOT NULL,
  `accepted` tinyint(1) NOT NULL DEFAULT '0',
  `shared_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index2` (`dataset`,`project`),
  KEY `fk_dataset_shared_with_2_idx` (`project`),
  CONSTRAINT `fk_dataset_shared_with_1` FOREIGN KEY (`dataset`) REFERENCES `dataset` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_dataset_shared_with_2` FOREIGN KEY (`project`) REFERENCES `project` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;


-- Insert existing shared datasets into new table
INSERT INTO hopsworks.dataset_shared_with (dataset, project, accepted)
SELECT hopsworks.dataset.id, datasetinfo.projectid, datasetinfo.shared
FROM hopsworks.dataset
         JOIN
     (
         SELECT hopsworks.dataset.id,
                hopsworks.dataset.inode_name as dataset_name,
                hopsworks.dataset.shared     as shared,
                hopsworks.project.id         as projectid,
                hopsworks.dataset.inode_pid
         FROM hopsworks.dataset
                  JOIN hopsworks.project ON hopsworks.dataset.projectId = hopsworks.project.id
                  JOIN hops.hdfs_inodes
                       ON hopsworks.project.inode_pid = hops.hdfs_inodes.parent_id
                           AND hopsworks.project.inode_name = hops.hdfs_inodes.name
                           AND hopsworks.project.partition_id = hops.hdfs_inodes.partition_id
                           AND hopsworks.dataset.inode_pid != hops.hdfs_inodes.id
     ) AS datasetinfo
     ON hopsworks.dataset.inode_name = datasetinfo.dataset_name
         AND hopsworks.dataset.inode_pid = datasetinfo.inode_pid
WHERE hopsworks.dataset.id NOT IN
      (
          SELECT hopsworks.dataset.id
          FROM hopsworks.dataset
                   JOIN hopsworks.project ON hopsworks.dataset.projectId = hopsworks.project.id
                   JOIN hops.hdfs_inodes
                        ON hopsworks.project.inode_pid = hops.hdfs_inodes.parent_id
                            AND hopsworks.project.inode_name = hops.hdfs_inodes.name
                            AND hopsworks.project.partition_id = hops.hdfs_inodes.partition_id
                            AND hopsworks.dataset.inode_pid != hops.hdfs_inodes.id
      );

-- Delete shared datasets from dataset table
DELETE hopsworks.dataset
FROM hopsworks.dataset
         JOIN (
    SELECT hops.hdfs_inodes.id as inode_id, hopsworks.project.projectname, hopsworks.project.id as project_id
    FROM hopsworks.project
             JOIN hops.hdfs_inodes
                  ON hopsworks.project.inode_pid = hops.hdfs_inodes.parent_id
                      AND hopsworks.project.inode_name = hops.hdfs_inodes.name
                      AND hopsworks.project.partition_id = hops.hdfs_inodes.partition_id
) AS projectinfo
              ON hopsworks.dataset.inode_pid = projectinfo.inode_id
                  AND hopsworks.dataset.projectId != projectinfo.project_id;

ALTER TABLE `hopsworks`.`dataset`
    DROP COLUMN `shared`,
    DROP COLUMN `status`,
    DROP COLUMN `editable`,
    DROP INDEX `uq_dataset`,
    ADD UNIQUE INDEX `uq_dataset` (`inode_pid`, `inode_name`, `partition_id`);

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`users` SET `tours_state`=0;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE hopsworks.`jupyter_settings` ADD COLUMN `python_kernel` tinyint(1) DEFAULT 1 AFTER `git_config_id`;
ALTER TABLE hopsworks.`jupyter_settings` ADD COLUMN `docker_config` VARCHAR(1000) COLLATE latin1_general_cs DEFAULT NULL AFTER `job_config`;

ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `desc_stats_enabled` TINYINT(1) NOT NULL DEFAULT '1';
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `feat_corr_enabled` TINYINT(1) NOT NULL DEFAULT '1';
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `feat_hist_enabled` TINYINT(1) NOT NULL DEFAULT '1';
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `cluster_analysis_enabled` TINYINT(1) NOT NULL DEFAULT '1';
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `num_clusters` int(11) NOT NULL DEFAULT '5';
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `num_bins` INT(11) NOT NULL DEFAULT '20';
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `corr_method` VARCHAR(50) NOT NULL DEFAULT 'pearson';

CREATE TABLE `statistic_columns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `feature_group_id` int(11) DEFAULT NULL,
  `name` varchar(500) COLLATE latin1_general_cs DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `feature_group_id` (`feature_group_id`),
  CONSTRAINT `statistic_column_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
