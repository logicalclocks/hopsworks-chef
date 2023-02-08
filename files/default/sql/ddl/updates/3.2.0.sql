CREATE TABLE IF NOT EXISTS `hdfs_command_execution` (
  `id` int NOT NULL AUTO_INCREMENT,
  `execution_id` int NOT NULL,
  `command` varchar(45) NOT NULL,
  `submitted` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `src_inode_pid` bigint NOT NULL,
  `src_inode_name` varchar(255) NOT NULL,
  `src_inode_partition_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_execution_id` (`execution_id`),
  UNIQUE KEY `uq_src_inode` (`src_inode_pid`,`src_inode_name`,`src_inode_partition_id`),
  KEY `fk_hdfs_file_command_1_idx` (`execution_id`),
  KEY `fk_hdfs_file_command_2_idx` (`src_inode_partition_id`,`src_inode_pid`,`src_inode_name`),
  CONSTRAINT `fk_hdfs_file_command_1` FOREIGN KEY (`execution_id`) REFERENCES `executions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_hdfs_file_command_2` FOREIGN KEY (`src_inode_partition_id`,`src_inode_pid`,`src_inode_name`) REFERENCES `hops`.`hdfs_inodes` (`partition_id`, `parent_id`, `name`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

DROP TABLE `shared_topics`;
DROP TABLE `topic_acls`;

UPDATE `project_team`
SET team_role = 'Data owner'
WHERE team_member = 'serving@hopsworks.se';
