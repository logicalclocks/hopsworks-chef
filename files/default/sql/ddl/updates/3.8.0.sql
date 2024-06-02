-- HWORKS-987
ALTER TABLE `hopsworks`.`model_version` ADD CONSTRAINT `model_version_key` UNIQUE (`model_id`,`version`);
ALTER TABLE `hopsworks`.`model_version` DROP PRIMARY KEY;
ALTER TABLE `hopsworks`.`model_version` ADD COLUMN id int(11) AUTO_INCREMENT PRIMARY KEY;

-- FSTORE-1190
ALTER TABLE `hopsworks`.`embedding_feature`
    ADD COLUMN `model_version_id` INT(11) NULL;

ALTER TABLE `hopsworks`.`embedding_feature`
    ADD CONSTRAINT `embedding_feature_model_version_fk` FOREIGN KEY (`model_version_id`) REFERENCES `model_version` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `api_protocol` TINYINT(1) NOT NULL DEFAULT '0';

-- FSTORE-1096
ALTER TABLE `hopsworks`.`feature_store_jdbc_connector`
    ADD COLUMN `secret_uid` INT DEFAULT NULL,
    ADD COLUMN `secret_name` VARCHAR(200) DEFAULT NULL;

-- FSTORE-1248
ALTER TABLE `hopsworks`.`executions`
    ADD COLUMN `notebook_out_path` varchar(255) COLLATE latin1_general_cs DEFAULT NULL;

CREATE TABLE IF NOT EXISTS `hopsworks`.`model_link` (
  `id` int NOT NULL AUTO_INCREMENT,
  `model_version_id` int(11) NOT NULL,
  `parent_training_dataset_id` int(11),
  `parent_feature_store` varchar(100) NOT NULL,
  `parent_feature_view_name` varchar(63) NOT NULL,
  `parent_feature_view_version` int(11) NOT NULL,
  `parent_training_dataset_version` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `link_unique` (`model_version_id`, `parent_training_dataset_id`),
  KEY `model_version_id_fkc` (`model_version_id`),
  KEY `parent_training_dataset_id_fkc` (`parent_training_dataset_id`),
  CONSTRAINT `model_version_id_fkc` FOREIGN KEY (`model_version_id`) REFERENCES `hopsworks`.`model_version` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `training_dataset_parent_fkc` FOREIGN KEY (`parent_training_dataset_id`) REFERENCES `hopsworks`.`training_dataset` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- FSTORE-920
ALTER TABLE `hopsworks`.`feature_store_jdbc_connector`
    ADD `driver_path` VARCHAR(2000) DEFAULT NULL;

-- CHANGES HWORKS-262
DROP TABLE `hopsworks`.`message_to_user`;

-- to avoid repeating the same code 100s of time we create a procedure here
DROP PROCEDURE IF EXISTS REPLACE_EMAIL_FK;

DELIMITER //

CREATE PROCEDURE REPLACE_EMAIL_FK(IN table_name VARCHAR(100), 
                                  IN old_column_name VARCHAR(100), IN new_column_name VARCHAR(100),
                                  IN old_fk_ref_table VARCHAR(100),
                                  IN index_name VARCHAR(100), IN fk_name VARCHAR(100))
BEGIN
    -- add the new column 
    SET @s := concat('ALTER TABLE hopsworks.', table_name, ' ADD COLUMN `', new_column_name ,'` INT(11)');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    -- update the uid values based on the emails
    SET SQL_SAFE_UPDATES = 0;
    SET @s := concat('UPDATE hopsworks.', table_name, ' t JOIN `hopsworks`.`users` u ON t.', old_column_name
                    , ' = u.email SET t.', new_column_name ,'= u.uid');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;
    SET SQL_SAFE_UPDATES = 1;

    -- now that the column has been populated, modify it to be not null
    -- this is needed to be able to build some unique indices/primary keys for some tables
    SET @s := concat('ALTER TABLE hopsworks.', table_name, ' MODIFY COLUMN `', new_column_name ,'` INT(11) NOT NULL');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    -- add fk constraint to the users table
    SET @s := concat('ALTER TABLE hopsworks.', table_name, ' ADD CONSTRAINT `', fk_name
                    , '` FOREIGN KEY (`', new_column_name 
                    ,'`) REFERENCES `hopsworks`.`users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    -- drop the existing foreign key  
    SET @fk_name = (SELECT k.CONSTRAINT_NAME 
	FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE k 
	WHERE k.TABLE_SCHEMA = "hopsworks" AND k.TABLE_NAME = table_name AND k.COLUMN_NAME = old_column_name AND k.REFERENCED_TABLE_NAME=old_fk_ref_table);

    SET @s := concat('ALTER TABLE hopsworks.', table_name , ' DROP FOREIGN KEY `', @fk_name, '`');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    -- drop the index created by the foreign key
    SET @s := concat('ALTER TABLE hopsworks.', table_name, ' DROP KEY `', index_name, '`');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    IF table_name = "jobs" THEN
        -- need to do it at this stage. earlier and the index is used by the old fk
        -- later and we can't drop the column as there is an index assigned to it
        ALTER TABLE `hopsworks`.`jobs` DROP KEY `creator_project_idx`;
    END IF;

    -- drop the original column
    SET @s := concat('ALTER TABLE hopsworks.', table_name, ' DROP COLUMN `', old_column_name, '`');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

END //

DELIMITER ;

-- welcome to the jungle.

CALL REPLACE_EMAIL_FK('jobs', 'creator', 'uid', 'users', 'creator', 'user_fk_jobs');
-- add the index back, but with the UID column 
ALTER TABLE `hopsworks`.`jobs` ADD KEY `uid_project_idx`(`uid`, `project_id`);

CALL REPLACE_EMAIL_FK('executions', 'user', 'uid', 'users', 'user', 'user_fk_executions');

-- dataset_request table has a FK to the project_team table that references project_id and email
-- we need to clean up the email from the dataset_request first then migrate the project_team
-- table and then add back the FK to the dataset_request table pointing to the new uid column
CALL REPLACE_EMAIL_FK('dataset_request', 'user_email', 'uid', 'project_team', 'projectId', 'project_team_fk');

-- the primary key for the project team table should be re-created to use uid instead of email
-- before being able to drop the primary key for the project_team, we need to add an index for the project_id
-- otherwise the drop primary key won't work as the project_id fk needs an index
ALTER TABLE `hopsworks`.`project_team` ADD INDEX `pid`(`project_id`);
ALTER TABLE `hopsworks`.`project_team` DROP PRIMARY KEY;
-- migrate the column
CALL REPLACE_EMAIL_FK('project_team', 'team_member', 'uid', 'users', 'team_member', 'user_fk_team');
-- add back the primary key using the uid column 
ALTER TABLE `hopsworks`.`project_team` ADD PRIMARY KEY(`project_id`, `uid`);

-- drop the foreign key created by the procedure above for dataset_request
-- and the proper one. This is done here to avoid having too much complexity 
-- on the stored procedure
ALTER TABLE `hopsworks`.`dataset_request` DROP FOREIGN KEY `project_team_fk`;
ALTER TABLE `hopsworks`.`dataset_request` DROP KEY `project_team_fk`;
ALTER TABLE `hopsworks`.`dataset_request`
    ADD CONSTRAINT `project_team_fk_ds` FOREIGN KEY (`projectId`,`uid`) 
    REFERENCES `project_team` (`project_id`,`uid`) ON DELETE CASCADE ON UPDATE NO ACTION;

-- team member is part of the primary key for both the jupyter_settings and rstudio_settings.
-- we need to add an index on the project id to be able to drop the primary key and re-create it
ALTER TABLE `hopsworks`.`jupyter_settings` ADD INDEX `pid`(`project_id`);
ALTER TABLE `hopsworks`.`jupyter_settings` DROP PRIMARY KEY;
CALL REPLACE_EMAIL_FK('jupyter_settings', 'team_member', 'uid', 'users', 'team_member', 'user_fk_jp_settings');
-- readd the primary key
ALTER TABLE `hopsworks`.`jupyter_settings` ADD PRIMARY KEY(`project_id`, `uid`);

ALTER TABLE `hopsworks`.`rstudio_settings` ADD INDEX `pid`(`project_id`);
ALTER TABLE `hopsworks`.`rstudio_settings` DROP PRIMARY KEY;
CALL REPLACE_EMAIL_FK('rstudio_settings', 'team_member', 'uid', 'users', 'team_member', 'user_fk_rstudio');
ALTER TABLE `hopsworks`.`rstudio_settings` ADD PRIMARY KEY(`project_id`, `uid`);

-- These are the easy ones that should not get tangled
CALL REPLACE_EMAIL_FK('project', 'username', 'uid', 'users', 'user_idx', 'user_fk_project');
CALL REPLACE_EMAIL_FK('message', 'user_from', 'uid_from', 'users', 'user_from', 'user_fk_msg_from');
CALL REPLACE_EMAIL_FK('message', 'user_to', 'uid_to', 'users', 'user_to', 'user_fk_msg_to');

-- END CHANGES HWORKS-262