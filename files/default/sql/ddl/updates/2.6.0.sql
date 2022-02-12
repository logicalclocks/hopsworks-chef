ALTER TABLE `hopsworks`.`feature_group_commit` ADD COLUMN `git_commit` VARCHAR(40) COLLATE latin1_general_cs DEFAULT
    NULL;
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `git_repository_id` INT COLLATE latin1_general_cs DEFAULT
    NULL;
ALTER TABLE `hopsworks`.`feature_group` ADD CONSTRAINT `fk_fg_gr` FOREIGN KEY (`git_repository_id`) REFERENCES
    `git_repositories` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `git_commit` VARCHAR(40) COLLATE latin1_general_cs DEFAULT
    NULL;
