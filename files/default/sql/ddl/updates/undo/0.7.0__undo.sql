ALTER TABLE `hopsworks`.`dataset` MODIFY COLUMN `inode_pid` INT(11);
ALTER TABLE `hopsworks`.`dataset` MODIFY COLUMN `partition_id` INT(11);
ALTER TABLE `hopsworks`.`dataset` MODIFY COLUMN `inode_id` INT(11);

ALTER TABLE `hopsworks`.`meta_data_schemaless` MODIFY COLUMN `inode_parent_id` INT(11);
ALTER TABLE `hopsworks`.`meta_data_schemaless` MODIFY COLUMN `inode_partition_id` INT(11);


ALTER TABLE `hopsworks`.`meta_inode_basic_metadata` MODIFY COLUMN `inode_pid` INT(11);
ALTER TABLE `hopsworks`.`meta_inode_basic_metadata` MODIFY COLUMN `partition_id` INT(11);

ALTER TABLE `hopsworks`.`meta_template_to_inode` MODIFY COLUMN `inode_pid` INT(11);
ALTER TABLE `hopsworks`.`meta_template_to_inode` MODIFY COLUMN `partition_id` INT(11);

ALTER TABLE `hopsworks`.`meta_tuple_to_file` MODIFY COLUMN `inodeid` INT(11);
ALTER TABLE `hopsworks`.`meta_tuple_to_file` MODIFY COLUMN `inode_pid` INT(11);
ALTER TABLE `hopsworks`.`meta_tuple_to_file` MODIFY COLUMN `partition_id` INT(11);

ALTER TABLE `hopsworks`.`project` MODIFY COLUMN `inode_pid` INT(11);
ALTER TABLE `hopsworks`.`project` MODIFY COLUMN `partition_id` INT(11);

ALTER TABLE `hopsworks`.`ops_log` MODIFY COLUMN `dataset_id` INT(11);
ALTER TABLE `hopsworks`.`ops_log` MODIFY COLUMN `inode_id` INT(11);

ALTER TABLE `hopsworks`.`meta_log` MODIFY COLUMN `meta_pk2` INT(11);
ALTER TABLE `hopsworks`.`meta_log` MODIFY COLUMN `meta_pk3` INT(11);

ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN `install_jupyter`;