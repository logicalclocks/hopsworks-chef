-- Create table without FK. FK will be added after we delete the shared datasets, otherwise the delete query will fail with FK constrain violation
CREATE TABLE IF NOT EXISTS `hopsworks`.`dataset_shared_with` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dataset` int(11) NOT NULL,
  `project` int(11) NOT NULL,
  `accepted` tinyint(1) NOT NULL DEFAULT '0',
  `shared_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index2` (`dataset`,`project`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

-- Populate the new table
INSERT INTO hopsworks.dataset_shared_with (dataset, project, accepted)
SELECT id as dataset, project_id as project, shared as accepted
FROM hopsworks.dataset JOIN (
    SELECT hops.hdfs_inodes.id as inode_id, hopsworks.project.projectname, hopsworks.project.id as project_id
    FROM hopsworks.project
             JOIN hops.hdfs_inodes
                  ON hopsworks.project.inode_pid = hops.hdfs_inodes.parent_id
                      AND hopsworks.project.inode_name = hops.hdfs_inodes.name
                      AND hopsworks.project.partition_id = hops.hdfs_inodes.partition_id
) AS projectinfo
    ON hopsworks.dataset.inode_pid = projectinfo.inode_id
        AND hopsworks.dataset.projectId != projectinfo.project_id;

-- Delete shared datasets from dataset table
DELETE hopsworks.dataset FROM hopsworks.dataset join (
    SELECT hops.hdfs_inodes.id as inode_id, hopsworks.project.projectname, hopsworks.project.id as project_id
    FROM hopsworks.project
             JOIN hops.hdfs_inodes
                  ON hopsworks.project.inode_pid = hops.hdfs_inodes.parent_id
                      AND hopsworks.project.inode_name = hops.hdfs_inodes.name
                      AND hopsworks.project.partition_id = hops.hdfs_inodes.partition_id
) AS projectinfo
    ON hopsworks.dataset.inode_pid = projectinfo.inode_id
        AND hopsworks.dataset.projectId != projectinfo.project_id;


-- Add foreign keys
ALTER TABLE `hopsworks`.`dataset_shared_with` ADD INDEX `fk_dataset_shared_with_1_idx` (`dataset` ASC), ADD INDEX `fk_dataset_shared_with_2_idx` (`project` ASC);
ALTER TABLE `hopsworks`.`dataset_shared_with` ADD CONSTRAINT `fk_dataset_shared_with_1`
    FOREIGN KEY (`dataset`)
        REFERENCES `hopsworks`.`dataset` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    ADD CONSTRAINT `fk_dataset_shared_with_2`
      FOREIGN KEY (`project`)
          REFERENCES `hopsworks`.`project` (`id`)
          ON DELETE NO ACTION
          ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`dataset`
    DROP COLUMN `shared`,
    DROP COLUMN `status`,
    DROP COLUMN `editable`,
    DROP COLUMN `inode_id`,
    DROP INDEX `uq_dataset` ,
    ADD UNIQUE INDEX `uq_dataset` (`inode_pid`, `inode_name`, `partition_id`),
    DROP INDEX `inode_id` ;