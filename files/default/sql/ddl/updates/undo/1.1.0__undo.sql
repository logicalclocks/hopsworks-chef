DROP TABLE IF EXISTS `hopsworks`.`dataset_shared_with`;

ALTER TABLE `hopsworks`.`dataset`
ADD `shared` tinyint(1) NOT NULL DEFAULT '0',
ADD `status` tinyint(1) NOT NULL DEFAULT '1',
ADD `editable` tinyint(1) NOT NULL DEFAULT '1',
ADD `inode_id` bigint(20) NOT NULL,
DROP INDEX `uq_dataset` ,
ADD UNIQUE INDEX `uq_dataset` (`inode_pid`,`projectId`,`inode_name`),
ADD INDEX `inode_id`;