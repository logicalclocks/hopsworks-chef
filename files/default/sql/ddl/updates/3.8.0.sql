--FSTORE-1190
ALTER TABLE `hopsworks`.`embedding_feature`
    ADD COLUMN `hsml_model_id` INT(11) NULL,
    ADD COLUMN `hsml_model_version` INT(11) NULL;

ALTER TABLE `hopsworks`.`embedding_feature`
    ADD CONSTRAINT `embedding_feature_model_version_fk` FOREIGN KEY (`hsml_model_id`, `hsml_model_version`) REFERENCES `model_version` (`model_id`, `version`) ON DELETE SET NULL ON UPDATE NO ACTION;
