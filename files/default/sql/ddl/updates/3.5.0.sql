-- FSTORE-1020
ALTER TABLE `hopsworks`.`training_dataset_filter_condition` DROP FOREIGN KEY `tdfc_feature_group_fk`;
ALTER TABLE `hopsworks`.`training_dataset_filter_condition` ADD FOREIGN KEY `tdfc_feature_group_fk`(`feature_group_id`)
    REFERENCES `hopsworks`.`feature_group` (`id`)
    ON DELETE SET NULL ON UPDATE NO ACTION;
