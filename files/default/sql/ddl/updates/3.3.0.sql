DROP PROCEDURE IF EXISTS `path_resolver`;
DROP FUNCTION IF EXISTS `path_resolver_fn`;

DELIMITER //
CREATE PROCEDURE path_resolver(IN `parent_id` BIGINT, 
                               OUT `inode_path` VARCHAR(255))
BEGIN
  DECLARE next_parent_id BIGINT;
  DECLARE inode_name VARCHAR(255);
  DECLARE parent_path VARCHAR(255);

  IF `parent_id` = 1 THEN
    -- We are at the root of the file system
    SET `inode_path` =  "/";
  ELSE

    -- Not the root, we need to traverse more.
    -- Get the information about the current inode
    SELECT `h`.`parent_id`, `h`.`name`
    INTO next_parent_id, inode_name
    FROM `hops`.`hdfs_inodes` `h`
    WHERE `h`.`id` = `parent_id`;

    -- Recursively traverse upstream
    CALL path_resolver(next_parent_id, parent_path);

    -- Assemble the path
    SET `inode_path` = CONCAT(parent_path, inode_name, "/");
  END IF;
END //


-- MySQL does not support recursive functions. 
-- Wrap the procedure above into a function to make the rest of the migrations easier
CREATE FUNCTION path_resolver_fn(`parent_id` BIGINT, `name` VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE parent_path VARCHAR(255);

  CALL path_resolver(`parent_id`, parent_path);

  RETURN CONCAT(parent_path, `name`);
END //

DELIMITER ;

-- HWORKS-480: Remove inode foreign key from git repositories
ALTER TABLE `hopsworks`.`git_repositories` ADD COLUMN `name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL;
ALTER TABLE `hopsworks`.`git_repositories` ADD COLUMN `path` VARCHAR(1000) COLLATE latin1_general_cs NOT NULL;

-- Migration
SET SQL_SAFE_UPDATES = 0;
UPDATE
    `hopsworks`.`git_repositories`
SET
    path = path_resolver_fn(`inode_pid`, `inode_name`);
SET SQL_SAFE_UPDATES = 1;

SET SQL_SAFE_UPDATES = 0;
UPDATE
    `hopsworks`.`git_repositories`
SET
    name = inode_name;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`git_repositories` DROP FOREIGN KEY `repository_inode_fk`;
ALTER TABLE `hopsworks`.`git_repositories` DROP KEY `repository_inode_constraint_unique`;
ALTER TABLE `hopsworks`.`git_repositories`
DROP COLUMN `inode_pid`,
    DROP COLUMN `inode_name`,
    DROP COLUMN `partition_id`;

ALTER TABLE `hopsworks`.`git_repositories` ADD UNIQUE KEY `repository_path_constraint_unique` (`path`);

-- HWORKS-515: Remove inode foreign key from feature_store_code
ALTER TABLE `hopsworks`.`feature_store_code` DROP FOREIGN KEY `inode_fk_fsc`;
ALTER TABLE `hopsworks`.`feature_store_code` DROP KEY `inode_fk_fsc`;
ALTER TABLE `hopsworks`.`feature_store_code` DROP COLUMN `inode_pid`, DROP COLUMN `partition_id`;
ALTER TABLE `hopsworks`.`feature_store_code` RENAME COLUMN `inode_name` TO `name`;

ALTER TABLE `hopsworks`.`feature_store` ADD COLUMN `name` varchar(100) COLLATE latin1_general_cs NOT NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`feature_store` `fs` 
  LEFT JOIN `project` `proj` ON `fs`.`project_id` = `proj`.`id`
SET `fs`.`name` = `proj`.`projectname`;
SET SQL_SAFE_UPDATES = 1;

-- HWORKS-486: Remove inode from project
ALTER TABLE `hopsworks`.`project` DROP FOREIGN KEY `FK_149_289`;
ALTER TABLE `hopsworks`.`project` DROP INDEX `inode_pid`;
ALTER TABLE `hopsworks`.`project` DROP COLUMN `inode_pid`;
ALTER TABLE `hopsworks`.`project` DROP COLUMN `inode_name`;
ALTER TABLE `hopsworks`.`project` DROP COLUMN `partition_id`;

-- HWORKS-523: Remove inode foreign key from transformation_function
ALTER TABLE `hopsworks`.`transformation_function` DROP FOREIGN KEY `inode_fn_fk`;
ALTER TABLE `hopsworks`.`transformation_function` DROP KEY `inode_fn_fk`;

ALTER TABLE `hopsworks`.`transformation_function` DROP COLUMN `inode_pid`, DROP COLUMN `partition_id`, DROP COLUMN `inode_name`;

-- FSTORE-840
ALTER TABLE `hopsworks`.`feature_store_kafka_connector` DROP FOREIGN KEY `fk_fs_storage_connector_kafka`;
ALTER TABLE `hopsworks`.`feature_store_kafka_connector` DROP KEY `fk_fs_storage_connector_kafka_idx`;

ALTER TABLE `hopsworks`.`feature_store_kafka_connector` DROP COLUMN `ssl_secret_uid`, DROP COLUMN `ssl_secret_name`, DROP COLUMN `ssl_endpoint_identification_algorithm`, DROP COLUMN `truststore_path`, DROP COLUMN `keystore_path`;

