-- FSTORE-1020
ALTER TABLE `hopsworks`.`training_dataset_filter_condition` DROP FOREIGN KEY `tdfc_feature_group_fk`;
ALTER TABLE `hopsworks`.`training_dataset_filter_condition` ADD FOREIGN KEY `tdfc_feature_group_fk`(`feature_group_id`)
    REFERENCES `hopsworks`.`feature_group` (`id`)
    ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`conda_commands` MODIFY COLUMN `created` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3);

DROP TABLE `hopsworks`.`pia`;

ALTER TABLE `hopsworks`.`oauth_client` ADD COLUMN `given_name_claim` VARCHAR(255) NOT NULL DEFAULT 'given_name';
ALTER TABLE `hopsworks`.`oauth_client` ADD COLUMN `family_name_claim` VARCHAR(255) NOT NULL DEFAULT 'family_name';
ALTER TABLE `hopsworks`.`oauth_client` ADD COLUMN `email_claim` VARCHAR(255) NOT NULL DEFAULT 'email';
ALTER TABLE `hopsworks`.`oauth_client` ADD COLUMN `group_claim` VARCHAR(255) DEFAULT NULL;

-- FSTORE-980: helper columns for feature view
ALTER TABLE `hopsworks`.`training_dataset_feature` ADD COLUMN `inference_helper_column` tinyint(1) DEFAULT '0';
ALTER TABLE `hopsworks`.`training_dataset_feature` ADD COLUMN `training_helper_column` tinyint(1) DEFAULT '0';

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
