-- FSTORE-1047
CREATE TABLE IF NOT EXISTS `embedding` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `feature_group_id` int(11) NOT NULL,
    `col_prefix` varchar(255) NULL,
    `vector_db_index_name` varchar(255) NOT NULL,
    PRIMARY KEY (`id`),
    KEY `feature_group_id` (`feature_group_id`),
    CONSTRAINT `feature_group_embedding_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
    ) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `embedding_feature` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `embedding_id` int(11) NOT NULL,
    `name` varchar(255) NOT NULL,
    `dimension` int NOT NULL,
    `similarity_function_type` varchar(255) NOT NULL,
    PRIMARY KEY (`id`),
    KEY `embedding_id` (`embedding_id`),
    CONSTRAINT `embedding_feature_fk` FOREIGN KEY (`embedding_id`) REFERENCES `embedding` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
    ) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `model` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `project_id` int(11) NOT NULL,
  UNIQUE KEY `project_unique_name` (`name`, `project_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `model_project_fk` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `model_version` (
  `model_id` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `user_id` int(10) NOT NULL,
  `created` timestamp DEFAULT NULL,
  `description` VARCHAR(1000) DEFAULT NULL,
  `metrics` VARCHAR(2000) DEFAULT NULL,
  `program` VARCHAR(1000) DEFAULT NULL,
  `framework` VARCHAR(128) DEFAULT NULL,
  `environment` VARCHAR(1000) DEFAULT NULL,
  `experiment_id` VARCHAR(128) DEFAULT NULL,
  `experiment_project_name` VARCHAR(128) DEFAULT NULL,
  PRIMARY KEY (`model_id`, `version`),
  CONSTRAINT `user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `model_fk` FOREIGN KEY (`model_id`) REFERENCES `model` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
