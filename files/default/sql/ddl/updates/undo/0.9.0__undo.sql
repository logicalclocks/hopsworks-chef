ALTER TABLE jupyter_project DROP FOREIGN KEY fk_hdfs_user_id;

ALTER TABLE jupyter_project DROP KEY unique_hdfs_user;

ALTER TABLE jupyter_project ADD KEY `hdfs_user_idx` (`hdfs_user_id`);

ALTER TABLE jupyter_project ADD CONSTRAINT `FK_103_525` FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;