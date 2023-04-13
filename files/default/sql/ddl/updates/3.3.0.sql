ALTER TABLE `hopsworks`.`feature_group_commit` DROP FOREIGN KEY `hopsfs_parquet_inode_fk`;
ALTER TABLE `hopsworks`.`feature_group_commit` DROP KEY `hopsfs_parquet_inode_fk`;
ALTER TABLE `hopsworks`.`feature_group_commit`
  DROP COLUMN `inode_pid`,
  DROP COLUMN `inode_name`,
  DROP COLUMN `partition_id`;

ALTER TABLE `hopsworks`.`feature_group_commit` ADD COLUMN `archived` TINYINT(1) NOT NULL DEFAULT '0';