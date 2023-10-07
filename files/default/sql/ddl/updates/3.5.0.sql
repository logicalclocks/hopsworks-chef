-- FSTORE-1020
ALTER TABLE `hopsworks`.`training_dataset_filter_condition` DROP FOREIGN KEY `tdfc_feature_group_fk`;
ALTER TABLE `hopsworks`.`training_dataset_filter_condition` ADD FOREIGN KEY `tdfc_feature_group_fk`(`feature_group_id`)
    REFERENCES `hopsworks`.`feature_group` (`id`)
    ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`conda_commands` MODIFY COLUMN `created` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3);

DROP TABLE `hopsworks`.`pia`;