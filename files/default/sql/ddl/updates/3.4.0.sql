-- HWORKS-626: conda environment history
CREATE TABLE IF NOT EXISTS `environment_history` (
                                       `id` int NOT NULL AUTO_INCREMENT,
                                       `project` int NOT NULL,
                                       `docker_image` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                                       `downgraded` varchar(7000) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                                       `installed` varchar(7000) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                                       `uninstalled` varchar(7000) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                                       `upgraded` varchar(7000) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
                                       `previous_docker_image` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
                                       `user` int NOT NULL,
                                       `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                       PRIMARY KEY (`id`),
                                       KEY `project` (`project`),
                                       KEY `docker_image` (`docker_image`)
                                           CONSTRAINT `env_project_fk` FOREIGN KEY (`project`) REFERENCES `project` (`id`) ON DELETE CASCADE
) ENGINE=ndbcluster AUTO_INCREMENT=69 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs

-- FSTORE-928: When hitting limit of number of projects that one user can create, deleting a project doesn't work as expected
ALTER TABLE `hopsworks`.`users` DROP COLUMN `num_created_projects`;

-- FSTORE-921
CREATE TABLE `serving_key` (
                               `id` int(11) NOT NULL AUTO_INCREMENT,
                               `prefix` VARCHAR(63) NULL DEFAULT '',
                               `feature_name` VARCHAR(1000) NOT NULL,
                               `join_on` VARCHAR(1000) NULL,
                               `join_index` int(11) NOT NULL,
                               `feature_group_id` INT(11) NOT NULL,
                               `required` tinyint(1) NOT NULL DEFAULT '0',
                               `feature_view_id` INT(11) NULL,
                               PRIMARY KEY (`id`),
                               KEY `feature_view_id` (`feature_view_id`),
                               KEY `feature_group_id` (`feature_group_id`),
                               CONSTRAINT `feature_view_serving_key_fk` FOREIGN KEY (`feature_view_id`) REFERENCES `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
                               CONSTRAINT `feature_group_serving_key_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- HWORKS-351: Add support to run generic docker commands
ALTER TABLE `hopsworks`.`conda_commands` MODIFY COLUMN `arg` VARCHAR(11000) DEFAULT NULL;
ALTER TABLE `hopsworks`.`conda_commands` ADD COLUMN `custom_commands_file` VARCHAR(255) DEFAULT NULL;
