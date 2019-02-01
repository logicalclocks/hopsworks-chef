ALTER TABLE jupyter_project ADD CONSTRAINT unique_hdfs_user UNIQUE (hdfs_user_id);

ALTER TABLE jupyter_project DROP FOREIGN KEY `FK_103_525`;

ALTER TABLE jupyter_project ADD CONSTRAINT `fk_hdfs_user_id` FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE jupyter_project DROP KEY `hdfs_user_idx`;