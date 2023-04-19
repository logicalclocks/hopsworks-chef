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