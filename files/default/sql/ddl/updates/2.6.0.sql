-- Add ModelFeature entity
CREATE TABLE `feature_view` (
                                 `id` int(11) NOT NULL AUTO_INCREMENT,
                                 `name` varchar(63) NOT NULL,
                                 `feature_store_id` int(11) NOT NULL,
                                 `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                                 `creator` int(11) NOT NULL,
                                 `version` int(11) NOT NULL,
                                 `description` varchar(10000) COLLATE latin1_general_cs DEFAULT NULL,
                                 `label` VARCHAR(255) NULL,
                                 PRIMARY KEY (`id`),
                                 UNIQUE KEY `name_version` (`feature_store_id`, `name`, `version`),
                                 KEY `feature_store_id` (`feature_store_id`),
                                 KEY `creator` (`creator`),
                                 CONSTRAINT `fv_creator_fk` FOREIGN KEY (`creator`) REFERENCES `users` (`uid`) ON
                                     DELETE NO ACTION ON UPDATE NO ACTION,
                                 CONSTRAINT `fv_feature_store_id_fk` FOREIGN KEY (`feature_store_id`) REFERENCES
                                     `feature_store` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `feature_view_id` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `td_feature_view_fk` FOREIGN KEY
    (`feature_view_id`) REFERENCES `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`training_dataset_join` ADD COLUMN `feature_view_id` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`training_dataset_join` ADD CONSTRAINT `tdj_feature_view_fk` FOREIGN KEY (`feature_view_id`) REFERENCES
    `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`training_dataset_feature` ADD COLUMN `feature_view_id` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`training_dataset_feature` ADD CONSTRAINT `tdf_feature_view_fk` FOREIGN KEY (`feature_view_id`)
    REFERENCES `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`feature_store_activity` ADD COLUMN `feature_view_id` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`feature_store_activity` ADD CONSTRAINT `fsa_feature_view_fk` FOREIGN KEY (`feature_view_id`) REFERENCES
    `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `start_time` TIMESTAMP NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `end_time` TIMESTAMP NULL;

CREATE TABLE IF NOT EXISTS `feature_store_kafka_connector` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `bootstrap_servers` VARCHAR(1000) NOT NULL,
    `security_protocol` VARCHAR(1000) NOT NULL,
    `ssl_secret_uid` INT NULL,
    `ssl_secret_name` VARCHAR(200) NULL,
    `ssl_endpoint_identification_algorithm` VARCHAR(100) NULL,
    `options` VARCHAR(2000) NULL,
    `truststore_inode_pid` BIGINT(20) NULL,
    `truststore_inode_name` VARCHAR(255) NULL,
    `truststore_partition_id` BIGINT(20) NULL,
    `keystore_inode_pid` BIGINT(20) NULL,
    `keystore_inode_name` VARCHAR(255) NULL,
    `keystore_partition_id` BIGINT(20) NULL,
    PRIMARY KEY (`id`),
    KEY `fk_fs_storage_connector_kafka_idx` (`ssl_secret_uid`, `ssl_secret_name`),
    CONSTRAINT `fk_fs_storage_connector_kafka` FOREIGN KEY (`ssl_secret_uid`, `ssl_secret_name`) REFERENCES `hopsworks`.`secrets` (`uid`, `secret_name`) ON DELETE RESTRICT,
    CONSTRAINT `fk_fs_storage_connector_kafka_truststore` FOREIGN KEY (
        `truststore_inode_pid`,
        `truststore_inode_name`,
        `truststore_partition_id`
    ) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fk_fs_storage_connector_kafka_keystore` FOREIGN KEY (
        `keystore_inode_pid`,
        `keystore_inode_name`,
        `keystore_partition_id`
    ) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_store_connector` ADD COLUMN `kafka_id` INT(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`feature_store_connector` ADD CONSTRAINT `fs_connector_kafka_fk` FOREIGN KEY (`kafka_id`) REFERENCES `hopsworks`.`feature_store_kafka_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`external_training_dataset`
    ADD COLUMN `inode_pid`  BIGINT(20) NOT NULL,
    ADD COLUMN `inode_name` VARCHAR(255) NOT NULL,
    ADD COLUMN `partition_id` BIGINT(20) NOT NULL,
    ADD CONSTRAINT `ext_td_inode_fk` FOREIGN KEY (`inode_pid`, `inode_name`, `partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `description` varchar(1000) COLLATE latin1_general_cs DEFAULT NULL;

-- Add StreamFeatureGroup
CREATE TABLE IF NOT EXISTS `stream_feature_group` (
                                                      `id`                             INT(11) NOT NULL AUTO_INCREMENT,
                                                      `offline_feature_group`          BIGINT(20) NOT NULL,
                                                      PRIMARY KEY (`id`),
                                                      CONSTRAINT `stream_fg_hive_fk` FOREIGN KEY (`offline_feature_group`) REFERENCES `metastore`.`TBLS` (`TBL_ID`) ON DELETE CASCADE ON UPDATE NO ACTION
)
ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `stream_feature_group_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`feature_group` ADD KEY `stream_feature_group_fk` (`stream_feature_group_id`);
ALTER TABLE `hopsworks`.`feature_group` ADD CONSTRAINT `stream_feature_group_fk` FOREIGN KEY (`stream_feature_group_id`) REFERENCES `stream_feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`cached_feature` ADD COLUMN `stream_feature_group_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`cached_feature` ADD KEY `stream_feature_group_fk2` (`stream_feature_group_id`);
ALTER TABLE `hopsworks`.`cached_feature` ADD CONSTRAINT `stream_feature_group_fk2` FOREIGN KEY (`stream_feature_group_id`) REFERENCES `stream_feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`cached_feature_extra_constraints` ADD COLUMN `stream_feature_group_id` INT(11) NULL;

ALTER TABLE `hopsworks`.`feature_group_commit` MODIFY COLUMN `committed_on` TIMESTAMP(6) NOT NULL;
CREATE TABLE hopsworks.feature_store_gcs_connector (
    id INT AUTO_INCREMENT PRIMARY KEY,
    key_path VARCHAR(500) NOT NULL,
    algorithm VARCHAR(10) NULL,
    encryption_key VARCHAR(100) NULL,
    encryption_key_hash VARCHAR(100) NULL
)  ENGINE=NDBCLUSTER DEFAULT CHARSET=LATIN1 COLLATE = LATIN1_GENERAL_CS;


ALTER TABLE hopsworks.feature_store_connector ADD COLUMN gcs_id INT;
ALTER TABLE hopsworks.feature_store_connector ADD CONSTRAINT fs_connector_gcs_fk FOREIGN KEY (gcs_id) REFERENCES hopsworks.feature_store_gcs_connector (id) ON DELETE CASCADE;
