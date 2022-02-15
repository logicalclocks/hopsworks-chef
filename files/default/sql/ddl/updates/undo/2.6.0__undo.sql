ALTER TABLE `hopsworks`.`feature_group_commit` DROP COLUMN `git_commit`;
ALTER TABLE `hopsworks`.`feature_group` DROP FOREIGN KEY `fk_fg_gr`, DROP COLUMN `git_repository_id`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `git_commit`;
