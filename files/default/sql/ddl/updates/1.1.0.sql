-- Create table without FK. FK will be added after we delete the shared datasets, otherwise the delete query will fail with FK constrain violation
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

-- Populate the new table
INSERT INTO hopsworks.dataset_shared_with (dataset, project, accepted)
SELECT hopsworks.dataset.id, datasetinfo.projectid, datasetinfo.shared
from hopsworks.dataset
     join
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
     ) as datasetinfo
        on hopsworks.dataset.inode_name = datasetinfo.dataset_name
             and hopsworks.dataset.inode_pid = datasetinfo.inode_pid
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



ALTER TABLE `hopsworks`.`dataset`
    DROP COLUMN `shared`,
    DROP COLUMN `status`,
    DROP COLUMN `editable`,
    DROP COLUMN `inode_id`,
    DROP INDEX `uq_dataset` ,
    ADD UNIQUE INDEX `uq_dataset` (`inode_pid`, `inode_name`, `partition_id`),
    DROP INDEX `inode_id` ;