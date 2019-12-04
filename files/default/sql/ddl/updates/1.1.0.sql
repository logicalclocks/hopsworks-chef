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
  `subject` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `compatibility` ENUM('BACKWARD', 'BACKWARD_TRANSITIVE', 'FORWARD', 'FORWARD_TRANSITIVE', 'FULL', 'FULL_TRANSITIVE', 'NONE') NOT NULL DEFAULT 'BACKWARD', 
  `project_id` int(11) NOT NULL,
  PRIMARY KEY (`subject`, `project_id`),
  CONSTRAINT `project_idx` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE `hopsworks`.`schemas` (
  `id` int(11) NOT NULL AUTO_INCREMENT, 
  `schema` varchar(10000) COLLATE latin1_general_cs NOT NULL,
  `project_id` int(11) NOT NULL,
  PRIMARY KEY (`id`, `project_id`),
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
		`project` p

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
		`project` p

-- create table "subjects"
CREATE TABLE `subjects` (
    `subject` VARCHAR(255) COLLATE LATIN1_GENERAL_CS NOT NULL,
    `version` INT(11) NOT NULL,
    `schema_id` INT(11) NOT NULL,
    `project_id` INT(11) NOT NULL,
    `created_on` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`subject` , `version` , `project_id`),
    KEY `project_id_idx` (`project_id`),
    KEY `created_on_idx` (`created_on`),
    CONSTRAINT `project_idx` FOREIGN KEY (`project_id`)
        REFERENCES `project` (`id`)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `schema_id_idx` FOREIGN KEY (`schema_id` , `project_id`)
        REFERENCES `schemas` (`id` , `project_id`)
        ON DELETE NO ACTION ON UPDATE NO ACTION
)  ENGINE=NDBCLUSTER DEFAULT CHARSET=LATIN1 COLLATE = LATIN1_GENERAL_CS;

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
					AND s.version = 1)

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
					AND s.version = 2)

-- find all schemas used by all topics and populate schemas table with them
REPLACE INTO `schemas` (`schema`, `project_id`)
	SELECT
		s.contents AS `schema`, p.project_id AS `project_id`
	FROM
		project_topics p
			JOIN
		schema_topics s ON p.schema_name = s.name
	GROUP BY s.contents , p.project_id;

-- populate subjects table with all schemas
REPLACE INTO `subjects` (`subject`, version, schema_id, project_id, created_on)
	SELECT
		st.`name` AS `subject`,
		st.version AS `version`,
		s.id AS `schema_id`,
		s.project_id AS `project_id`,
		st.created_on AS `created_on`
	FROM
		`schema_topics` st
			JOIN
		`schemas` s ON st.contents = s.`schema`
			RIGHT JOIN
		`project_topics` p ON p.schema_name = st.name
			AND p.schema_version = st.version;

-- drop related foreign key
ALTER TABLE `hopsworks`.`project_topics`
  DROP FOREIGN KEY `schema_idx`;

-- drop schema_topics
DROP TABLE IF EXISTS `schema_topics`;

-- alter project_topics columns
ALTER TABLE `hopsworks`.`project_topics`
	DROP FOREIGN KEY `schema_idx`,
	CHANGE COLUMN `schema_name` `subject` VARCHAR(255) CHARACTER SET 'latin1' COLLATE 'latin1_general_cs' NOT NULL ,
	CHANGE COLUMN `schema_version` `subject_version` INT(11) NOT NULL ,
	DROP INDEX `schema_idx` ,
	ADD INDEX `subject_idx_idx` (`subject` ASC, `subject_version` ASC, `project_id` ASC),
	ADD CONSTRAINT `subject_idx`
		FOREIGN KEY (`subject` , `subject_version` , `project_id`)
		REFERENCES `hopsworks`.`subjects` (`subject` , `version` , `project_id`)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION;
