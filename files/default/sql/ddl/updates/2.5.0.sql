UPDATE 
  `hopsworks`.`feature_store_expectation_rule` fs_expt_rule,

  (SELECT `feature_store_expectation_id`, `validation_rule_id`, `temp_val_rule`.`id`
   FROM `hopsworks`.`feature_store_expectation_rule` fs_expt_rule_inn
   JOIN `hopsworks`.`validation_rule` val_rule ON val_rule.id = fs_expt_rule_inn.validation_rule_id 
   JOIN (SELECT MAX(id) AS id, name FROM `hopsworks`.`validation_rule` GROUP BY name) temp_val_rule ON temp_val_rule.name = val_rule.name) max_rules_id

SET `fs_expt_rule`.`validation_rule_id` = `max_rules_id`.`id`

WHERE 
      `fs_expt_rule`.`feature_store_expectation_id` = `max_rules_id`.feature_store_expectation_id AND 
      `fs_expt_rule`.validation_rule_id = `max_rules_id`.`validation_rule_id`;

DELETE FROM `hopsworks`.`validation_rule` WHERE `id` NOT IN (SELECT DISTINCT(validation_rule_id) FROM `hopsworks`.`feature_store_expectation_rule`);

ALTER TABLE `hopsworks`.`validation_rule` MODIFY COLUMN description VARCHAR(200) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`validation_rule` DROP INDEX `unique_validation_rule`;
ALTER TABLE `hopsworks`.`validation_rule` ADD CONSTRAINT `unique_validation_rule` UNIQUE KEY (`name`);

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `model_name` varchar(255) COLLATE latin1_general_cs NOT NULL AFTER `transformer`;
ALTER TABLE `hopsworks`.`serving` ADD COLUMN `predictor` varchar(255) COLLATE latin1_general_cs DEFAULT NULL;

ALTER TABLE `hopsworks`.`api_key` ADD COLUMN `reserved` tinyint(1) DEFAULT '0';

-- Set model_name column, parse the model path on format /Projects/{project}/Models/{model} and get the model name
SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`serving`
SET `model_name` = (SELECT REPLACE(SUBSTRING(SUBSTRING_INDEX(`model_path`, '/', 5), LENGTH(SUBSTRING_INDEX(`model_path`, '/', 4)) + 1), '/', ''));
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`executions` DROP FOREIGN KEY `FK_347_365`;

CREATE TABLE `cached_feature` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cached_feature_group_id` int(11) NULL,
  `name` varchar(63) COLLATE latin1_general_cs NOT NULL,
  `description` varchar(256) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `cached_feature_group_fk` (`cached_feature_group_id`),
  CONSTRAINT `cached_feature_group_fk2` FOREIGN KEY (`cached_feature_group_id`) REFERENCES `cached_feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`on_demand_feature_group` MODIFY COLUMN `query` VARCHAR(26000) COLLATE latin1_general_cs DEFAULT NULL;

CREATE TABLE `hopsworks`.`oauth_token` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `id_token` varchar(8000) COLLATE latin1_general_cs NOT NULL,
  `access_token` varchar(8000) COLLATE latin1_general_cs DEFAULT NULL,
  `refresh_token` varchar(8000) COLLATE latin1_general_cs DEFAULT NULL,
  `login_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `login_state_UNIQUE` (`user_id`),
  KEY `fk_oauth_token_user` (`user_id`),
  CONSTRAINT `fk_oauth_token_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`uid`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`oauth_login_state` ADD COLUMN `id_token` VARCHAR(8000) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`oauth_login_state` ADD COLUMN `refresh_token` VARCHAR(8000) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`oauth_login_state` RENAME COLUMN `token` TO `access_token`;

ALTER TABLE `hopsworks`.`feature_store_statistic` ADD COLUMN `for_transformation` TINYINT(1) DEFAULT '0';

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `train_split` VARCHAR(63) COLLATE latin1_general_cs DEFAULT NULL;

-- training dataset filter table
CREATE TABLE IF NOT EXISTS `hopsworks`.`training_dataset_filter` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `training_dataset_id` INT(11) NULL,
    `type` VARCHAR(63) NULL,
    `path` VARCHAR(63) NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT `tdf_training_dataset_fk` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopsworks`.`training_dataset_filter_condition` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `training_dataset_filter_id` INT(11) NULL,
    `feature_group_id` INT(11) NULL,
    `feature_name` VARCHAR(63) NULL,
    `filter_condition` VARCHAR(128) NULL,
    `filter_value` VARCHAR(1024) NULL,
    `filter_value_fg_id` INT(11) NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT `tdfc_training_dataset_filter_fk` FOREIGN KEY (`training_dataset_filter_id`) REFERENCES `training_dataset_filter` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `tdfc_feature_group_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`variables` ADD COLUMN `hide` TINYINT NOT NULL DEFAULT 0;
ALTER TABLE `hopsworks`.`conda_commands` DROP COLUMN `user`;

CREATE TABLE IF NOT EXISTS `git_repositories` (
                                                `id` int NOT NULL AUTO_INCREMENT,
                                                `inode_pid` bigint NOT NULL,
                                                `inode_name` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                                                `partition_id` bigint NOT NULL,
                                                `project` int NOT NULL,
                                                `provider` varchar(20) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                                                `current_branch` varchar(250) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                                                `current_commit` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                                                `cid` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                                                `creator` int NOT NULL,
                                                PRIMARY KEY (`id`),
                                                UNIQUE KEY `repository_inode_constraint_unique` (`inode_pid`,`inode_name`,`partition_id`),
                                                KEY `project_fk` (`project`),
                                                CONSTRAINT `project_fk` FOREIGN KEY (`project`) REFERENCES `project` (`id`) ON DELETE CASCADE,
                                                CONSTRAINT `repository_inode_fk` FOREIGN KEY (`inode_pid`, `inode_name`, `partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`) ON DELETE CASCADE
) ENGINE=ndbcluster AUTO_INCREMENT=2061 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `git_executions` (
                                                `id` int NOT NULL AUTO_INCREMENT,
                                                `submission_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                `user` int NOT NULL,
                                                `repository` int NOT NULL,
                                                `execution_start` bigint DEFAULT NULL,
                                                `execution_stop` bigint DEFAULT NULL,
                                                `command_config` varchar(11000) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                                                `state` varchar(128) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                                                `final_result_message` varchar(11000) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                                                `config_secret` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                                                PRIMARY KEY (`id`),
                                                KEY `user` (`user`),
                                                KEY `git_exec_repo_fkc` (`repository`),
                                                CONSTRAINT `git_exec_repo_fkc` FOREIGN KEY (`repository`) REFERENCES `git_repositories` (`id`) ON DELETE CASCADE,
                                                CONSTRAINT `git_exec_usr_fkc` FOREIGN KEY (`user`) REFERENCES `users` (`uid`) ON DELETE CASCADE
) ENGINE=ndbcluster AUTO_INCREMENT=8251 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `git_commits` (
                                            `id` int NOT NULL AUTO_INCREMENT,
                                            `repository` int NOT NULL,
                                            `branch` varchar(250) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                                            `hash` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                                            `message` varchar(1000) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                                            `committer_name` varchar(1000) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                                            `committer_email` varchar(1000) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                                            `date` TIMESTAMP NULL DEFAULT NULL,
                                            PRIMARY KEY (`id`),
                                            KEY `repository_fk` (`repository`),
                                            CONSTRAINT `repository_fk` FOREIGN KEY (`repository`) REFERENCES `git_repositories` (`id`) ON DELETE CASCADE
) ENGINE=ndbcluster AUTO_INCREMENT=4119 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `git_repository_remotes` (
                                                        `id` int NOT NULL AUTO_INCREMENT,
                                                        `repository` int NOT NULL,
                                                        `remote_name` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                                                        `remote_url` varchar(1000) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                                                        PRIMARY KEY (`id`),
                                                        KEY `git_repository_fk` (`repository`),
                                                        CONSTRAINT `git_repository_fk` FOREIGN KEY (`repository`) REFERENCES `git_repositories` (`id`) ON DELETE CASCADE
 ) ENGINE=ndbcluster AUTO_INCREMENT=6164 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
