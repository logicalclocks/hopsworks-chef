-- FSTORE-1285
ALTER TABLE `hopsworks`.`training_dataset_feature` DROP FOREIGN KEY `tfn_fk_tdf`;
ALTER TABLE `hopsworks`.`training_dataset_feature` DROP `transformation_function`;

ALTER TABLE `hopsworks`.`transformation_function` ADD COLUMN `save_type` VARCHAR(255)    NOT NULL; 
ALTER TABLE `hopsworks`.`transformation_function` ADD COLUMN `statistics_argument_names` VARCHAR(5004); 

CREATE TABLE IF NOT EXISTS `hopsworks`.`feature_view_transformation_function` (
    `id`                                INT(11)         NOT NULL AUTO_INCREMENT,
    `transformation_function_id` int(11) NOT NULL,
    `feature_view_id` int(11) NOT NULL,
    `features` VARCHAR(5004) NOT NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT `fvtf_fvi_fk` FOREIGN KEY (`feature_view_id`) REFERENCES `feature_view` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fvtf_tfi_fk` FOREIGN KEY (`transformation_function_id`) REFERENCES `transformation_function` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

-- FSTORE-1411
ALTER TABLE `hopsworks`.`training_dataset_feature` ADD COLUMN `on_demand_feature` BOOLEAN NOT NULL;
ALTER TABLE `hopsworks`.`transformation_function` ADD COLUMN `dropped_argument_names` VARCHAR(5004);
ALTER TABLE `hopsworks`.`transformation_function` ADD COLUMN `transformation_function_argument_names` VARCHAR(5004) NOT NULL;

CREATE TABLE IF NOT EXISTS `hopsworks`.`feature_group_transformation_functions` ( -- mapping transformation functions in feature view with required features and actual transformation function.
    `id`                                INT(11)         NOT NULL AUTO_INCREMENT,
    `transformation_function_id` int(11) NOT NULL,
    `feature_group_id` int(11) NOT NULL,
    `features` VARCHAR(5004) NOT NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT `fgtf_fgi_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fgtf_tfi_fk` FOREIGN KEY (`transformation_function_id`) REFERENCES `transformation_function` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;