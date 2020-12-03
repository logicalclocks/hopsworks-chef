SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "conda_commands" AND REFERENCED_TABLE_NAME="project");
# If fk does not exist, then just execute "SELECT 1"
SET @s = (SELECT IF((@fk_name) is not null,
                    concat('ALTER TABLE hopsworks.conda_commands DROP FOREIGN KEY `', @fk_name, '`'),
                    "SELECT 1"));
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cached_feature` (
CREATE TABLE `cached_feature_extra_constraints` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cached_feature_group_id` int(11) NULL,
  `hive_column_pk_cdId` BIGINT(20) NOT NULL,
  `hive_column_int_idx` int(11) NOT NULL,
  `primary_column` tinyint(1) NOT NULL DEFAULT '0',
  `hudi_precombine_key` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `cached_feature_group_fk` (`cached_feature_group_id`),
  CONSTRAINT `cached_feature_group_fk1` FOREIGN KEY (`cached_feature_group_id`) REFERENCES `cached_feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_group_commit` MODIFY `committed_on` DATETIME(6);

ALTER TABLE `hopsworks`.`conda_commands` CHANGE `environment_yml` `environment_file` VARCHAR(1000) COLLATE latin1_general_cs DEFAULT NULL;