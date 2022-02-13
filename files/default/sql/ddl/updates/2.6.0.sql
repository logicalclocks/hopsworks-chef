
CREATE TABLE IF NOT EXISTS `stream_feature_group` (
                                                      `id`                             INT(11) NOT NULL AUTO_INCREMENT,
                                                      `offline_feature_group`          BIGINT(20) NOT NULL,
                                                      PRIMARY KEY (`id`),
                                                      `job_id` int(11) NULL,
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