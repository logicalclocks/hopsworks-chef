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
