ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `stream_feature_group_id`;
ALTER TABLE `hopsworks`.`feature_group` DROP KEY `stream_feature_group_fk`;
ALTER TABLE `hopsworks`.`feature_group` DROP CONSTRAINT `stream_feature_group_fk`;
ALTER TABLE `hopsworks`.`cached_feature_extra_constraints` DROP COLUMN `stream_feature_group_id`;
DROP TABLE IF EXISTS `hopsworks`.`stream_feature_group`;
