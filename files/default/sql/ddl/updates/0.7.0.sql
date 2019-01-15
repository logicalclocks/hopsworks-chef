DROP TABLE IF EXISTS  `hopsworks`.`file_activity`;

ALTER TABLE `hopsworks`.`dataset` MODIFY COLUMN `inode_pid` BIGINT(20);
ALTER TABLE `hopsworks`.`dataset` MODIFY COLUMN `partition_id` BIGINT(20);
ALTER TABLE `hopsworks`.`dataset` MODIFY COLUMN `inode_id` BIGINT(20);

ALTER TABLE `hopsworks`.`meta_data_schemaless` MODIFY COLUMN `inode_parent_id` BIGINT(20);
ALTER TABLE `hopsworks`.`meta_data_schemaless` MODIFY COLUMN `inode_partition_id` BIGINT(20);

ALTER TABLE `hopsworks`.`meta_inode_basic_metadata` MODIFY COLUMN `inode_pid` BIGINT(20);
ALTER TABLE `hopsworks`.`meta_inode_basic_metadata` MODIFY COLUMN `partition_id` BIGINT(20);

ALTER TABLE `hopsworks`.`meta_template_to_inode` MODIFY COLUMN `inode_pid` BIGINT(20);
ALTER TABLE `hopsworks`.`meta_template_to_inode` MODIFY COLUMN `partition_id` BIGINT(20);

ALTER TABLE `hopsworks`.`meta_tuple_to_file` MODIFY COLUMN `inodeid` BIGINT(20);
ALTER TABLE `hopsworks`.`meta_tuple_to_file` MODIFY COLUMN `inode_pid` BIGINT(20);
ALTER TABLE `hopsworks`.`meta_tuple_to_file` MODIFY COLUMN `partition_id` BIGINT(20);

ALTER TABLE `hopsworks`.`project` MODIFY COLUMN `inode_pid` BIGINT(20);
ALTER TABLE `hopsworks`.`project` MODIFY COLUMN `partition_id` BIGINT(20);

ALTER TABLE `hopsworks`.`ops_log` MODIFY COLUMN `dataset_id` BIGINT(20);
ALTER TABLE `hopsworks`.`ops_log` MODIFY COLUMN `inode_id` BIGINT(20);

ALTER TABLE `hopsworks`.`meta_log` MODIFY COLUMN `meta_pk2` BIGINT(20);
ALTER TABLE `hopsworks`.`meta_log` MODIFY COLUMN `meta_pk3` BIGINT(20);

ALTER TABLE `hopsworks`.`conda_commands` ADD COLUMN `install_jupyter` tinyint(1) NOT NULL DEFAULT '0';