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
  CONSTRAINT `fk_dataset_shared_with_1` FOREIGN KEY (`dataset`) REFERENCES `dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_dataset_shared_with_2` FOREIGN KEY (`project`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
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


-- Get all the hive db and feature store datasets that are shared and insert them into dataset_shared_with
-- The query gets the dataset id of the parent dataset and the projectIDs for each of the project the parent dataset
-- has been shared with
INSERT INTO hopsworks.dataset_shared_with (dataset, project, accepted)
SELECT datasetinfo2.id, datasetinfo1.projectid, datasetinfo1.accepted
FROM (
         SELECT dataset1.inode_name, dataset1.projectid, dataset1.shared as accepted
         FROM hopsworks.dataset as dataset1
              -- find get /apps/hive/warehouse inode id
         WHERE hopsworks.dataset1.inode_pid = (SELECT id
                                               FROM hops.hdfs_inodes
                                               WHERE name = 'warehouse' AND parent_id =
                                                     (SELECT id
                                                      FROM hops.hdfs_inodes
                                                      WHERE name = 'hive'
                                                        AND parent_id = (select id FROM hops.hdfs_inodes WHERE name = 'apps' AND
                                                            parent_id = 1)))
           -- for older, non hive datasets, we do not used the shared flag as it is not a safe indicator of a shared dataset
           AND shared = 1) as datasetinfo1
         JOIN (
            SELECT dataset1.id, dataset1.inode_name, dataset1.projectid, dataset1.shared as accepted
            FROM hopsworks.dataset as dataset1
                 -- find get /apps/hive/warehouse inode id
            WHERE hopsworks.dataset1.inode_pid = (SELECT id
                                                  FROM hops.hdfs_inodes
                                                  WHERE name = 'warehouse'
                                                    AND parent_id =
                                                        (SELECT id
                                                         FROM hops.hdfs_inodes
                                                         WHERE name = 'hive'
                                                           AND parent_id =
                                                               (SELECT id FROM hops.hdfs_inodes WHERE name = 'apps' AND parent_id = 1)))
              -- for older, non hive datasets, we do not used the shared flag as it is not a safe indicator of a shared dataset
      AND shared = 0) as datasetinfo2
              ON datasetinfo1.inode_name = datasetinfo2.inode_name;

-- Delete shared hive and feature_store datasets
DELETE
FROM hopsworks.dataset
WHERE shared = 1
  AND hopsworks.dataset.inode_pid = (SELECT id
                                     FROM hops.hdfs_inodes
                                     WHERE name = 'warehouse'
                                       AND parent_id =
                                           (SELECT id
                                            FROM hops.hdfs_inodes
                                            WHERE name = 'hive' AND parent_id =
                                              (SELECT id FROM hops.hdfs_inodes WHERE name = 'apps' AND parent_id = 1)));



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

CREATE TABLE `hopsworks`.`subjects_compatibility` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `compatibility` ENUM('BACKWARD', 'BACKWARD_TRANSITIVE', 'FORWARD', 'FORWARD_TRANSITIVE', 'FULL', 'FULL_TRANSITIVE', 'NONE') NOT NULL DEFAULT 'BACKWARD', 
  `project_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `subjects_compatibility__constraint_key` UNIQUE (`subject`, `project_id`),
  CONSTRAINT `project_idx` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE `hopsworks`.`schemas` (
  `id` int(11) NOT NULL AUTO_INCREMENT, 
  `schema` varchar(10000) COLLATE latin1_general_cs NOT NULL,
  `project_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `project_idx` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- add project compatibility for all projects
INSERT INTO `subjects_compatibility` (`subject`, compatibility, project_id)
	SELECT
		'projectcompatibility' AS `subject`,
		'BACKWARD' AS compatibility,
		p.id AS project_id
	FROM
		`project` p;

-- add inferenceschema compatibility for all projects
INSERT INTO `subjects_compatibility` (`subject`, compatibility, project_id)
	SELECT
		'inferenceschema' AS `subject`,
		'NONE' AS compatibility,
		p.id AS project_id
	FROM
		`project` p;

-- add inference schemas to schemas table
REPLACE INTO `schemas`(`schema`, `project_id`)
	SELECT 
		(SELECT 
				s.contents AS `schema`
			FROM
				`schema_topics` s
			WHERE
				s.name = 'inferenceschema'
					AND s.version = 1),
		p.id AS project_id
	FROM
		`project` p;

REPLACE INTO `schemas`(`schema`, `project_id`)
	SELECT 
		(SELECT 
				s.contents AS `schema`
			FROM
				`schema_topics` s
			WHERE
				s.name = 'inferenceschema'
					AND s.version = 2),
		p.id AS project_id
	FROM
		`project` p;

-- create table "subjects"
CREATE TABLE `subjects` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `subject` VARCHAR(255) COLLATE LATIN1_GENERAL_CS NOT NULL,
    `version` INT(11) NOT NULL,
    `schema_id` INT(11) NOT NULL,
    `project_id` INT(11) NOT NULL,
    `created_on` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `project_id_idx` (`project_id`),
    KEY `created_on_idx` (`created_on`),
    CONSTRAINT `project_idx` FOREIGN KEY (`project_id`)
        REFERENCES `project` (`id`)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `schema_id_idx` FOREIGN KEY (`schema_id`)
        REFERENCES `schemas` (`id`)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `subjects__constraint_key` UNIQUE (`subject`, `version`, `project_id`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs; 

-- add inference schemas to all the projects
REPLACE INTO `subjects` (`subject`, version, schema_id, project_id, created_on)
	SELECT 
		'inferenceschema' AS `subject`,
		1 AS version,
		s.id AS `schema_id`,
		s.project_id AS project_id,
		CURRENT_TIMESTAMP AS created_on
	FROM
		`schemas` s
	WHERE
		s.schema = (SELECT 
				s.contents AS `schema`
			FROM
				`schema_topics` s
			WHERE
				s.name = 'inferenceschema'
					AND s.version = 1);

REPLACE INTO `subjects` (`subject`, version, schema_id, project_id, created_on)
	SELECT 
		'inferenceschema' AS `subject`,
		2 AS version,
		s.id AS `schema_id`,
		s.project_id AS project_id,
		CURRENT_TIMESTAMP AS created_on
	FROM
		`schemas` s
	WHERE
		s.schema = (SELECT 
				s.contents AS `schema`
			FROM
				`schema_topics` s
			WHERE
				s.name = 'inferenceschema'
					AND s.version = 2);

-- find all schemas used by all topics and populate schemas table with them
REPLACE INTO `schemas` (`schema`, `project_id`)
  SELECT
      s.contents AS `schema`, p.project_id AS `project_id`
  FROM
      project_topics p
          JOIN
      schema_topics s ON p.schema_name = s.name
          AND p.schema_version = s.version
  GROUP BY `schema` , `project_id`;

-- populate subjects table with all schemas
REPLACE INTO `subjects` (`subject`, version, schema_id, project_id, created_on)
	SELECT 
		st.`name` AS `subject`,
		st.version AS `version`,
		s.id AS `schema_id`,
		p.project_id AS `project_id`,
		st.created_on AS `created_on`
	FROM
		`project_topics` p
			JOIN
		`schema_topics` st ON p.schema_name = st.name
			AND p.schema_version = st.version
			JOIN
		`schemas` s ON st.contents = s.`schema`
			AND p.project_id = s.project_id;

-- drop related foreign key
ALTER TABLE `hopsworks`.`project_topics`
  DROP FOREIGN KEY `schema_idx`,
  DROP KEY `schema_name_idx`,
  DROP KEY `schema_idx`;

-- drop schema_topics
DROP TABLE IF EXISTS `schema_topics`;

-- add subject_id column
ALTER TABLE `hopsworks`.`project_topics`
  ADD COLUMN `subject_id` int(11) NOT NULL;

-- fill subject_id based on the subject name and version
SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`project_topics` pt
        JOIN
    `hopsworks`.`subjects` s ON pt.`schema_name` = s.`subject`
        AND pt.`schema_version` = s.`version`
        AND pt.`project_id` = s.`project_id`
SET
    pt.`subject_id` = s.`id`;
SET SQL_SAFE_UPDATES = 1;

-- alter project_topics columns
ALTER TABLE `hopsworks`.`project_topics`
	DROP COLUMN `schema_name`,
  DROP COLUMN `schema_version`,
	ADD CONSTRAINT `subject_idx`
		FOREIGN KEY (`subject_id`)
		REFERENCES `hopsworks`.`subjects` (`id`)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION;


ALTER TABLE `hopsworks`.`executions` ADD COLUMN `args` VARCHAR(10000) NOT NULL DEFAULT '' AFTER `hdfs_user`;

ALTER TABLE `hopsworks`.`tensorboard` CHANGE `elastic_id` `ml_id` varchar(100) COLLATE latin1_general_cs NOT NULL;

-- Truncate conda commands due to NON_NULL user_id which breaks FK
TRUNCATE TABLE `hopsworks`.`conda_commands`;

ALTER TABLE `hopsworks`.`conda_commands` ADD COLUMN  `user_id` int(11) NOT NULL;
ALTER TABLE `hopsworks`.`conda_commands` ADD FOREIGN KEY `user_fk` (`user_id`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION;
