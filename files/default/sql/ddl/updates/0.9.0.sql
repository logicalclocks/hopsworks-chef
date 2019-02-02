ALTER TABLE jupyter_project ADD CONSTRAINT unique_hdfs_user UNIQUE (hdfs_user_id);

-- Find the name of the FK
SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "jupyter_project" AND REFERENCED_TABLE_NAME="hdfs_users");
SET @s := concat('ALTER TABLE hopsworks.jupyter_project DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;


ALTER TABLE jupyter_project ADD CONSTRAINT `fk_hdfs_user_id` FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE jupyter_project DROP KEY `hdfs_user_idx`;