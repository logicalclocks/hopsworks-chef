-- revert feature monitoring changes
DROP TABLE IF EXISTS `hopsworks`.`feature_monitoring_result`;
DROP TABLE IF EXISTS `hopsworks`.`feature_descriptive_statistics`;
DROP TABLE IF EXISTS `hopsworks`.`feature_monitoring_config`;
DROP TABLE IF EXISTS `hopsworks`.`monitoring_window_config`;
DROP TABLE IF EXISTS `hopsworks`.`statistics_comparison_config`;
DROP TABLE IF EXISTS `hopsworks`.`job_schedule`;
DROP TABLE IF EXISTS `hopsworks`.`feature_view_alert`;