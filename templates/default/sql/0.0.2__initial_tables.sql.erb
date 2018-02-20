ALTER TABLE `flyway_schema_history` engine=ndb;

CREATE TABLE IF NOT EXISTS `bbc_group` (
    `group_name` VARCHAR(20) NOT NULL,
    `group_desc` VARCHAR(200) DEFAULT NULL,
    `gid` INT(11) NOT NULL,
     PRIMARY KEY (`gid`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


CREATE TABLE IF NOT EXISTS `users` (
    `uid` INT(11) NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(10)  NOT NULL,
    `password` VARCHAR(128)  NOT NULL,
    `email` VARCHAR(150)  DEFAULT NULL,
    `fname` VARCHAR(30)  DEFAULT NULL,
    `lname` VARCHAR(30)  DEFAULT NULL,
    `activated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `title` VARCHAR(10)  DEFAULT '-',
    `orcid` VARCHAR(20)  DEFAULT '-',
    `false_login` INT(11) NOT NULL DEFAULT '-1',
    `status` INT(11) NOT NULL DEFAULT '-1',
    `isonline` INT(11) NOT NULL DEFAULT '-1',
    `secret` VARCHAR(20)  DEFAULT NULL,
    `validation_key` VARCHAR(128)  DEFAULT NULL,
    `security_question` VARCHAR(20)  DEFAULT NULL,
    `security_answer` VARCHAR(128)  DEFAULT NULL,
    `mode` INT(11) NOT NULL DEFAULT '0',
    `password_changed` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `notes` VARCHAR(500)  DEFAULT '-',
    `mobile` VARCHAR(15)  DEFAULT '-',
    `max_num_projects` INT(11) NOT NULL,
    `num_active_projects` INT(11) NOT NULL DEFAULT '0',    
    `num_created_projects` INT(11) NOT NULL DEFAULT '0',
    `two_factor` tinyint(1) NOT NULL DEFAULT '1',
    `tours_state` tinyint(1) NOT NULL DEFAULT '0',
    `salt` VARCHAR(128) NOT NULL DEFAULT '',
    PRIMARY KEY (`uid`),
    UNIQUE KEY `username` (`username`),
    UNIQUE KEY `email` (`email`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs AUTO_INCREMENT=10000;

CREATE TABLE IF NOT EXISTS `address` (
    `address_id` INT(11) NOT NULL AUTO_INCREMENT,
    `uid` INT(11) NOT NULL,
    `address1` VARCHAR(100) DEFAULT '-',
    `address2` VARCHAR(100) DEFAULT '-',
    `address3` VARCHAR(100) DEFAULT '-',
    `city` VARCHAR(40) DEFAULT 'San Francisco',
    `state` VARCHAR(50) DEFAULT 'CA',
    `country` VARCHAR(40) DEFAULT 'US',
    `postalcode` VARCHAR(10) DEFAULT '-',
    PRIMARY KEY (`address_id`),
    FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `user_group` (
    `uid` INT(11) NOT NULL,
    `gid` INT(11) NOT NULL,
    PRIMARY KEY (`uid`,`gid`),
    FOREIGN KEY (`gid`) REFERENCES `bbc_group` (`gid`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


CREATE TABLE IF NOT EXISTS `account_audit` (
    `log_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
    `initiator` INT(11) NOT NULL,
    `target` INT(11) NOT NULL,
    `action` VARCHAR(45) DEFAULT NULL,
    `action_timestamp` TIMESTAMP NULL DEFAULT NULL,
    `message` VARCHAR(100) DEFAULT NULL,
    `outcome` VARCHAR(45) DEFAULT NULL,
    `ip` VARCHAR(45) DEFAULT NULL,
    `useragent` VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (`log_id`),
    KEY `initiator` (`initiator`),
    KEY `target` (`target`),
    FOREIGN KEY (`initiator`) REFERENCES `users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (`target`) REFERENCES `users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


CREATE TABLE IF NOT EXISTS `roles_audit` (
    `log_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
    `target` INT(11) NOT NULL,
    `initiator` INT(11) NOT NULL,
    `action` VARCHAR(45) DEFAULT NULL,
    `action_timestamp` TIMESTAMP NULL DEFAULT NULL,
    `message` VARCHAR(45) DEFAULT NULL,
    `ip` VARCHAR(45) DEFAULT NULL,
    `outcome` VARCHAR(45) DEFAULT NULL,
    `useragent` VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (`log_id`),
    KEY `initiator` (`initiator`),
    KEY `target` (`target`),
    FOREIGN KEY (`initiator`) REFERENCES `users` (`uid`),
    FOREIGN KEY (`target`) REFERENCES `users` (`uid`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `project` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `inode_pid` INT(11) NOT NULL,
  `inode_name` VARCHAR(255) NOT NULL,
  `partition_id` INT(11) NOT NULL,
  `projectname` VARCHAR(100) NOT NULL,
  `username` VARCHAR(150) NOT NULL,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `retention_period` DATE DEFAULT NULL,
  `archived` TINYINT(1) DEFAULT '0',
  `conda` TINYINT(1) DEFAULT '0',
  `logs` TINYINT(1) DEFAULT '0',
  `deleted` TINYINT(1) DEFAULT '0',
  `python_version` VARCHAR(25) DEFAULT NULL,
  `description` VARCHAR(2000) DEFAULT NULL,
  `payment_type` VARCHAR(255) NOT NULL DEFAULT 'PREPAID',
  `last_quota_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY(`projectname`),
  UNIQUE KEY(`inode_pid`, `inode_name`,	`partition_id`),
  KEY user_idx(`username`),
  FOREIGN KEY (`username`) REFERENCES `users` (`email`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (`inode_pid`,`inode_name`, `partition_id`) REFERENCES `hops`.`hdfs_inodes`(`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `activity` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `activity` VARCHAR(128) NOT NULL,
  `user_id` INT(10) NOT NULL,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `flag` VARCHAR(128) DEFAULT NULL,
  `project_id` INT(11) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`uid`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `project_services` (
  `project_id` INT(11) NOT NULL,
  `service` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`project_id`,`service`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `project_team` (
  `project_id` INT(11) NOT NULL,
  `team_member` VARCHAR(150) NOT NULL,
  `team_role` VARCHAR(32) NOT NULL,
  `added` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`project_id`,`team_member`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`team_member`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `jupyter_settings` (
  `project_id` INT(11) NOT NULL,
  `team_member` VARCHAR(150) NOT NULL,
  `num_tf_ps` INT(11) DEFAULT '1',
  `num_tf_gpus` INT(11) DEFAULT '0',
  `num_mpi_np` INT(11) DEFAULT '1',
  `appmaster_cores` INT(11) DEFAULT '1',
  `appmaster_memory` INT(11) DEFAULT '1024',
  `num_executors` INT(11) DEFAULT '1',
  `num_executor_cores` INT(11) DEFAULT '1',
  `executor_memory` INT(11) DEFAULT '1024',
  `dynamic_initial_executors` INT(11) DEFAULT '1',
  `dynamic_min_executors` INT(11) DEFAULT '1',
  `dynamic_max_executors` INT(11) DEFAULT '1',
  `secret` VARCHAR(255) NOT NULL,
  `log_level` VARCHAR(32) NULL DEFAULT 'INFO',
  `mode` VARCHAR(32) NOT NULL,
  `umask` VARCHAR(32) DEFAULT '022',  
  `advanced` tinyint(1) DEFAULT '0',
  `archives` VARCHAR(1500) DEFAULT '',
  `jars` VARCHAR(1500) DEFAULT '',
  `files` VARCHAR(1500) DEFAULT '',
  `py_files` VARCHAR(1500) DEFAULT '',
  `spark_params` VARCHAR(6500) DEFAULT '',
  PRIMARY KEY (`project_id`,`team_member`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`team_member`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE NO ACTION,
  KEY secret_idx(`secret`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `tf_serving` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `host_ip` VARCHAR(255) DEFAULT NULL,
  `port` INT(11) DEFAULT NULL,
  `pid` BIGINT DEFAULT NULL,
  `status` VARCHAR(50) NOT NULL,
  `project_id` INT(11) NOT NULL,
  `hdfs_user_id` int(11) NOT NULL,
  `created` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `creator` VARCHAR(150) NOT NULL,
  `model_name` VARCHAR(255) NOT NULL,
  `hdfs_model_path` VARCHAR(255) NOT NULL,
  `version` INT(11) NOT NULL,
  `secret` VARCHAR(255) NOT NULL,
  `enable_batching` TINYINT(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `hdfs_user_idx` (`hdfs_user_id`),
  CONSTRAINT Serving_Constraint UNIQUE(project_id, model_name),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`creator`) REFERENCES `users` (`email`) ON DELETE NO ACTION ON UPDATE NO ACTION
  ) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `schema_topics` (
  `name` VARCHAR(255) NOT NULL,
  `version` INT(11) NOT NULL,
  `contents` VARCHAR(10000) NOT NULL,
  `created_on` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   KEY created_on_idx (created_on),
   PRIMARY KEY (`name`,`version`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `project_topics` (
  `topic_name` VARCHAR(255) NOT NULL,
  `project_id` INT(11) NOT NULL,
  `schema_name` VARCHAR(255) NOT NULL,
  `schema_version` INT(11) NOT NULL,
  PRIMARY KEY (`topic_name`,`project_id`),
  KEY schema_name_idx (schema_name),
  FOREIGN KEY `project_idx` (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY `schema_idx` (`schema_name`,`schema_version`) REFERENCES `schema_topics` (`name`,`version`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs /*!50100 PARTITION BY KEY (topic_name) */ ;

CREATE TABLE IF NOT EXISTS `shared_topics` (
  `topic_name` VARCHAR(255) NOT NULL,
  `project_id` INT(11) NOT NULL,
  `owner_id` INT(11) NOT NULL,
  PRIMARY KEY (`project_id`,`topic_name`),
  FOREIGN KEY `topic_idx` (`topic_name`, `owner_id`) REFERENCES `project_topics` (`topic_name`, `project_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs /*!50100 PARTITION BY KEY (topic_name) */ ;

CREATE TABLE IF NOT EXISTS `topic_acls` (
 `id` INT(11) NOT NULL AUTO_INCREMENT,
 `topic_name` VARCHAR(255) NOT NULL,
 `project_id` INT(11) NOT NULL,
 `username` VARCHAR(150) NOT NULL,
 `principal` VARCHAR(170) NOT NULL,
 `permission_type` VARCHAR(255) NOT NULL,
 `operation_type` VARCHAR(255) NOT NULL,
 `host` VARCHAR(255) NOT NULL,
 `role` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`username`) REFERENCES `users` (`email`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY `topic_idx` (`topic_name`, `project_id`) REFERENCES `project_topics` (`topic_name`, `project_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs ;

CREATE TABLE IF NOT EXISTS `userlogins` (
    `login_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
    `ip` VARCHAR(45) DEFAULT NULL,
    `useragent` VARCHAR(255) DEFAULT NULL,
    `action` VARCHAR(80) DEFAULT NULL,
    `outcome` VARCHAR(20) DEFAULT NULL,
    `uid` INT(11) NOT NULL,
    `login_date` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`login_id`),
    KEY (`login_date`),
    FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


CREATE TABLE IF NOT EXISTS `jobs` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(128) DEFAULT NULL,
  `creation_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `project_id` INT(11) NOT NULL,
  `creator` VARCHAR(150) NOT NULL,
  `type` VARCHAR(128) NOT NULL,
  `json_config` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY name_idx (`name`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`creator`) REFERENCES `users` (`email`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `jobs_history` (
  `job_id` INT(11) NOT NULL,
  `jar_file` VARCHAR(255) NOT NULL,
  `execution_id` INT(11) NOT NULL,
  `app_id` CHAR(30) DEFAULT NULL,
  `job_type` VARCHAR(255) NOT NULL,
  `class_name` VARCHAR(255) NOT NULL,
  `arguments` TEXT NOT NULL,
  `input_blocks_in_hdfs` INT(11) NOT NULL,
  `am_memory` INT(11) NOT NULL,
  `am_Vcores` INT(11) NOT NULL,
  `execution_duration` BIGINT(20) DEFAULT NULL,
  `queuing_time` BIGINT(20) DEFAULT NULL,
  `user_email` VARCHAR(150) NOT NULL,
  `project_name` VARCHAR(100) NOT NULL,
  `job_name` VARCHAR(128) DEFAULT NULL,
  `state` VARCHAR(128) DEFAULT NULL,
  `final_status` VARCHAR(128) DEFAULT NULL,
  `project_id` INT(11) DEFAULT NULL,
  PRIMARY KEY (`execution_id`),
  UNIQUE KEY `inode_idx` (`app_id`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `executions` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `submission_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user` VARCHAR(150) NOT NULL,
  `state` VARCHAR(128) NOT NULL,
  `execution_start` BIGINT(20) DEFAULT NULL,
  `execution_stop` BIGINT(20) DEFAULT NULL,
  `stdout_path` VARCHAR(255) DEFAULT NULL,
  `stderr_path` VARCHAR(255) DEFAULT NULL,
  `hdfs_user` VARCHAR(255) DEFAULT NULL,
  `app_id` CHAR(30) DEFAULT NULL,
  `job_id` INT(11) NOT NULL,
  `finalStatus` VARCHAR(128) NOT NULL DEFAULT 'UNDEFINED',
  `progress` FLOAT NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE (`app_id`),
  FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`user`) REFERENCES `users` (`email`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `job_output_files` (
  `execution_id` INT(11) NOT NULL,
  `path` VARCHAR(255) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`execution_id`,`name`),
  FOREIGN KEY (`execution_id`) REFERENCES `executions` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `job_input_files` (
  `execution_id` INT(11) NOT NULL,
  `path` VARCHAR(255) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`execution_id`,`name`),
  FOREIGN KEY (`execution_id`) REFERENCES `executions` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `files_to_remove` (
  `execution_id` INT(11) NOT NULL,
  `filepath` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`execution_id`,`filepath`),
  FOREIGN KEY (`execution_id`) REFERENCES `executions` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


CREATE TABLE IF NOT EXISTS `organization` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `uid` INT(11) DEFAULT NULL,
    `org_name` VARCHAR(100) DEFAULT '-',
    `website` VARCHAR(2083) DEFAULT '-',
    `contact_person` VARCHAR(100) DEFAULT '-',
    `contact_email` VARCHAR(150) DEFAULT '-',
    `department` VARCHAR(100) DEFAULT '-',
    `phone` VARCHAR(20) DEFAULT '-',
    `fax` VARCHAR(20) DEFAULT '-',
    PRIMARY KEY (`id`),
    FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- ------------------------
-- Metadata --------------
-- ------------------------

CREATE TABLE IF NOT EXISTS `meta_templates` (
  `templateid` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(250) NOT NULL,
  PRIMARY KEY (`templateid`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `meta_field_types` (
  `id` MEDIUMINT(9) NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `meta_tables` (
  `tableid` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) DEFAULT NULL,
  `templateid` INT(11) NOT NULL,
  PRIMARY KEY (`tableid`),
  FOREIGN KEY (`templateid`) REFERENCES `meta_templates` (`templateid`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `meta_fields` (
  `fieldid` INT(11) NOT NULL AUTO_INCREMENT,
  `maxsize` INT(11) DEFAULT NULL,
  `name` VARCHAR(255) DEFAULT NULL,
  `required` TINYINT(1) DEFAULT NULL,
  `searchable` TINYINT(1) DEFAULT NULL,
  `tableid` INT(11) DEFAULT NULL,
  `type` VARCHAR(255) DEFAULT NULL,
  `ftype` MEDIUMINT(11) DEFAULT 3,
  `description` VARCHAR(250) NOT NULL,
  `fieldtypeid` MEDIUMINT(11) NOT NULL,
  `position` MEDIUMINT(11) DEFAULT '0',
  PRIMARY KEY (`fieldid`),
  FOREIGN KEY (`tableid`) REFERENCES `meta_tables` (`tableid`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (`fieldtypeid`) REFERENCES `meta_field_types` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `meta_field_predefined_values` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `fieldid` INT(11) NOT NULL,
  `valuee` VARCHAR(250) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`fieldid`) REFERENCES `meta_fields` (`fieldid`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `meta_tuple_to_file` (
  `tupleid` INT(11) NOT NULL AUTO_INCREMENT,
  `inodeid` INT(11) NOT NULL, -- pretty necessary for the rivers to work
  `inode_pid` INT(11) NOT NULL,
  `inode_name` VARCHAR(255) NOT NULL,
  `partition_id` INT(11) NOT NULL,
  PRIMARY KEY (`tupleid`),
  FOREIGN KEY (`inode_pid`, `inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `meta_raw_data` (
  `fieldid` INT(11) NOT NULL,
  `tupleid` INT(11) NOT NULL,
  PRIMARY KEY (`fieldid`, `tupleid`),
  FOREIGN KEY (`fieldid`) REFERENCES `meta_fields` (`fieldid`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (`tupleid`) REFERENCES `meta_tuple_to_file` (`tupleid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `meta_data` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `data` VARCHAR(12000) NOT NULL,
  `fieldid` INT(11) NOT NULL,
  `tupleid` INT(11) NOT NULL,
  PRIMARY KEY (`id`, `fieldid`, `tupleid`),
  FOREIGN KEY (`fieldid`, `tupleid`) REFERENCES `meta_raw_data` (`fieldid`, `tupleid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `meta_template_to_inode` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `template_id` INT(11) NOT NULL,
  `inode_pid` INT(11) NOT NULL,
  `inode_name` VARCHAR(255) NOT NULL,
  `partition_id` INT(11) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`template_id`) REFERENCES `meta_templates` (`templateid`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`inode_pid`,`inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes`(`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `meta_inode_basic_metadata` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `inode_pid` INT(11) NOT NULL,
  `inode_name` VARCHAR(255) NOT NULL,
  `partition_id` INT(11) NOT NULL,
  `description` VARCHAR(3000) DEFAULT NULL,
  `searchable` TINYINT(1) NOT NULL DEFAULT '0',
  PRIMARY KEY(`id`),
  UNIQUE KEY (`inode_pid`, `inode_name`,`partition_id`),
  FOREIGN KEY (`inode_pid`, `inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes`(`parent_id`, `name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `meta_data_schemaless` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inode_id` int(11) NOT NULL,
  `inode_parent_id` int(11) NOT NULL,
  `inode_name` varchar(255) NOT NULL,
  `inode_partition_id` int(11) NOT NULL,
  `data` varchar(12000) NOT NULL,
  PRIMARY KEY (`id`, `inode_id`, `inode_parent_id`),
  UNIQUE KEY (`inode_parent_id`, `inode_name`,`inode_partition_id`),
  FOREIGN KEY (`inode_parent_id`, `inode_name`,`inode_partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- Dataset table-------------------------------------------------
CREATE TABLE IF NOT EXISTS `dataset` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `inode_pid` INT(11) NOT NULL,
  `inode_name` VARCHAR(255) NOT NULL,
  `inode_id` INT(11) NOT NULL,
  `partition_id` INT(11) NOT NULL,
  `projectId` INT(11) NOT NULL,
  `description` VARCHAR(2000) DEFAULT NULL,
  `editable` TINYINT(1) NOT NULL DEFAULT '1',
  `status` TINYINT(1) NOT NULL DEFAULT '1',
  `searchable` TINYINT(1) NOT NULL DEFAULT '0',
  `public_ds` TINYINT(1) NOT NULL DEFAULT '0',
  `public_ds_id` varchar(1000) DEFAULT '0',
  `shared` TINYINT(1) NOT NULL DEFAULT '0',
  `dstype` INT(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_dataset` (`inode_pid`,`projectId`,`inode_name`),
  KEY `inode_id` (`inode_id`),
  KEY `projectId_name` (`projectId`, `inode_name`),
  FOREIGN KEY (`projectId`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`inode_pid`,`inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;



-- Message
-- ------------------------
CREATE TABLE IF NOT EXISTS `message` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_from` varchar(150) DEFAULT NULL,
  `user_to` varchar(150)  NOT NULL,
  `date_sent` datetime NOT NULL,
  `subject` varchar(128)  DEFAULT NULL,
  `preview` varchar(128) DEFAULT NULL,
  `content` text  NOT NULL,
  `unread` tinyint(1) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `path` varchar(600) DEFAULT NULL,
  `reply_to_msg` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`user_from`) REFERENCES `users` (`email`) ON DELETE SET NULL ON UPDATE NO ACTION,
  FOREIGN KEY (`user_to`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`reply_to_msg`) REFERENCES `message` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `dataset_request` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `dataset` INT(11) NOT NULL,
  `projectId` INT(11) NOT NULL,
  `user_email` VARCHAR(150) NOT NULL,
  `requested` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `message` VARCHAR(3000) DEFAULT NULL,
  `message_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index2` (`dataset`,`projectId`),
  FOREIGN KEY (`projectId`,`user_email`)
   REFERENCES `project_team` (`project_id`,`team_member`)
   ON DELETE CASCADE
   ON UPDATE NO ACTION,
  FOREIGN KEY (`dataset`)
   REFERENCES `dataset` (`id`)
   ON DELETE CASCADE
   ON UPDATE NO ACTION,
  FOREIGN KEY (`message_id`)
   REFERENCES `message` (`id`)
   ON DELETE NO ACTION
   ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


CREATE TABLE IF NOT EXISTS `message_to_user` (
  `message` int(11) NOT NULL,
  `user_email` varchar(150) NOT NULL,
  PRIMARY KEY (`message`,`user_email`),
  FOREIGN KEY (`user_email`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`message`) REFERENCES `message` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


 CREATE TABLE IF NOT EXISTS `variables` (
  `id` varchar(255) NOT NULL,
  `value` varchar(1024) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


-- Cert Access -----------
-- -----------------------

-- ATTENTION
-- CERTS ARE BOUND TO PROJECTNAME+USERID
-- UPDATED FOREIGN KEYS MIGHT LEAVE US WITH STALE DATA
CREATE TABLE IF NOT EXISTS `user_certs` (
	`projectname` VARCHAR(100) NOT NULL,
	`username` VARCHAR(10)  NOT NULL,
	`user_key` VARBINARY(7000),
	`user_cert` VARBINARY(3000),
        `user_key_pwd` varchar(200) DEFAULT NULL,
	PRIMARY KEY (`projectname`, `username`),
	FOREIGN KEY (`projectname`) REFERENCES `project` (`projectname`) ON DELETE CASCADE ON UPDATE NO ACTION,
	FOREIGN KEY (`username`) REFERENCES `users` (`username`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


CREATE TABLE IF NOT EXISTS `projectgenericuser_certs` (
  `project_generic_username` varchar(120) COLLATE latin1_general_cs NOT NULL,
  `pgu_key` varbinary(7000) DEFAULT NULL,
  `pgu_cert` varbinary(3000) DEFAULT NULL,
  `cert_password` varchar(200) COLLATE latin1_general_cs NOT NULL DEFAULT '',
  PRIMARY KEY (`project_generic_username`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


CREATE TABLE IF NOT EXISTS `ssh_keys` (
  `uid` INT(11) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `public_key` VARCHAR(2000) NOT NULL,
  PRIMARY KEY (`uid`, `name`),
  FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


CREATE TABLE authorized_sshkeys (project VARCHAR(64) NOT NULL, user VARCHAR(48) NOT NULL, sshkey_name VARCHAR(64) NOT NULL, PRIMARY KEY (project, user, sshkey_name), KEY idx_user(user), KEY idx_project(project)) engine=ndbcluster;

-- File Activity Table
--

CREATE TABLE IF NOT EXISTS `file_activity`
(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `activity` varchar(128) NOT NULL,
  `hdfs_user_id` int(11) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `parent_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `partition_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `hdfs_user_idx` (`hdfs_user_id`),
  KEY `inode_idx` (`parent_id`, `name`),
  CONSTRAINT `FK_144_466` FOREIGN KEY (`parent_id`,`name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_134_321` FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;



--
-- DR ELEPHANT TABLES
--


-- CREATE TABLE IF NOT EXISTS yarn_app_result (
--   id              VARCHAR(50)   NOT NULL,
--   name            TEXT          ,
--   username        VARCHAR(50)   NOT NULL,
--   queue_name      TEXT          ,
--   start_time      BIGINT        UNSIGNED NOT NULL,
--   finish_time     BIGINT        UNSIGNED NOT NULL,
--   tracking_url    TEXT          ,
--   job_type        VARCHAR(50)   NOT NULL DEFAULT '',
--   severity        TINYINT(2)    UNSIGNED NOT NULL,
--   score           MEDIUMINT(9)  UNSIGNED DEFAULT 0,
--   workflow_depth  TINYINT(2)    UNSIGNED DEFAULT 0,
--   scheduler       TEXT          ,
--   job_name        TEXT          ,
--   job_exec_id     TEXT          ,
--   flow_exec_id    VARCHAR(128)  NOT NULL DEFAULT '',
--   job_def_id      VARCHAR(128)  NOT NULL DEFAULT '',
--   flow_def_id     VARCHAR(128)  NOT NULL DEFAULT '',
--   job_exec_url    TEXT          ,
--   flow_exec_url   TEXT          ,
--   job_def_url     TEXT          ,
--   flow_def_url    TEXT          ,
--   PRIMARY KEY (id)
-- );

-- create index yarn_app_result_i1 on yarn_app_result (finish_time);
-- create index yarn_app_result_i2 on yarn_app_result (username,finish_time);
-- create index yarn_app_result_i3 on yarn_app_result (job_type,username,finish_time);
-- create index yarn_app_result_i4 on yarn_app_result (flow_exec_id);
-- create index yarn_app_result_i5 on yarn_app_result (job_def_id);
-- create index yarn_app_result_i6 on yarn_app_result (flow_def_id);
-- create index yarn_app_result_i7 on yarn_app_result (start_time);

-- CREATE TABLE IF NOT EXISTS yarn_app_heuristic_result (
--   id                  INT(11)       NOT NULL AUTO_INCREMENT,
--   yarn_app_result_id  VARCHAR(50)   NOT NULL,
--   heuristic_class     TEXT          ,
--   heuristic_name      VARCHAR(128)  NOT NULL,
--   severity            TINYINT(2)    UNSIGNED NOT NULL,
--   score               MEDIUMINT(9)  UNSIGNED DEFAULT 0,
--   PRIMARY KEY (id),
--   CONSTRAINT yarn_app_heuristic_result_f1 FOREIGN KEY (yarn_app_result_id) REFERENCES yarn_app_result (id)
-- );

-- create index yarn_app_heuristic_result_i1 on yarn_app_heuristic_result (yarn_app_result_id);
-- create index yarn_app_heuristic_result_i2 on yarn_app_heuristic_result (heuristic_name,severity);

-- CREATE TABLE IF NOT EXISTS yarn_app_heuristic_result_details (
--   yarn_app_heuristic_result_id  INT(11)          NOT NULL,
--   name                          VARCHAR(128)     NOT NULL DEFAULT '',
--   value                         TEXT             ,
--   details                       TEXT             ,
--   PRIMARY KEY (yarn_app_heuristic_result_id,name),
--   CONSTRAINT yarn_app_heuristic_result_details_f1 FOREIGN KEY (yarn_app_heuristic_result_id) REFERENCES yarn_app_heuristic_result (id)
-- );

-- create index yarn_app_heuristic_result_details_i1 on yarn_app_heuristic_result_details (name);


-- ------------------------
-- ePipe
-- ------------------------

CREATE TABLE IF NOT EXISTS `ops_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `op_id` int(11) NOT NULL,
  `op_on` tinyint(1) NOT NULL,
  `op_type` tinyint(1) NOT NULL,
  `project_id` int(11) NOT NULL,
  `dataset_id` int(11) NOT NULL,
  `inode_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `meta_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meta_pk1` int(11) NOT NULL,
  `meta_pk2` int(11) NOT NULL,
  `meta_pk3` int(11) NOT NULL,
  `meta_type` tinyint(1) NOT NULL,
  `meta_op_type` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- ------------------------
-- kmon
-- ------------------------

CREATE TABLE IF NOT EXISTS `hosts` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `hostname` varchar(128) NOT NULL,
  `cores` int(11) DEFAULT NULL,
  `disk_capacity` bigint(20) DEFAULT NULL,
  `disk_used` bigint(20) DEFAULT NULL,
  `host_ip` varchar(128) NOT NULL,
  `last_heartbeat` bigint(20) DEFAULT NULL,
  `load1` double DEFAULT NULL,
  `load15` double DEFAULT NULL,
  `load5` double DEFAULT NULL,
  `memory_capacity` bigint(20) DEFAULT NULL,
  `memory_used` bigint(20) DEFAULT NULL,
  `private_ip` varchar(15) DEFAULT NULL,
  `public_ip` varchar(15) DEFAULT NULL,
  `agent_password` varchar(25) DEFAULT NULL,
  `has_gpus` tinyint(1) DEFAULT '0',
  `registered` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY (`hostname`),
  KEY (`host_ip`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `alerts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `current_value` varchar(32) DEFAULT NULL,
  `failure_max` varchar(32) DEFAULT NULL,
  `failure_min` varchar(32) DEFAULT NULL,
  `warning_max` varchar(32) DEFAULT NULL,
  `warning_min` varchar(32) DEFAULT NULL,
  `agent_time` bigint(20) DEFAULT NULL,
  `alert_time` datetime DEFAULT NULL,
  `data_source` varchar(128) DEFAULT NULL,
  `host_id` int(11) DEFAULT NULL,
  `message` varchar(1024) NOT NULL,
  `plugin` varchar(128) DEFAULT NULL,
  `plugin_instance` varchar(128) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `severity` varchar(255) DEFAULT NULL,
  `type` varchar(128) DEFAULT NULL,
  `type_instance` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`host_id`) REFERENCES `hosts` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;



CREATE TABLE IF NOT EXISTS `host_services` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cluster` varchar(48) NOT NULL,
  `host_id` int(11) NOT NULL,
  `pid` int(11) DEFAULT NULL,
  `service` varchar(48) NOT NULL,
  `group_name` varchar(48) NOT NULL,
  `status` int(11) NOT NULL,
  `uptime` bigint(20) DEFAULT NULL,
  `webport` int(11) DEFAULT NULL,
  `startTime` bigint(20) DEFAULT NULL,
  `stopTime` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`host_id`) REFERENCES `hosts` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `commands` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cluster` varchar(48) NOT NULL,
  `command` varchar(255) NOT NULL,
  `end_time` datetime DEFAULT NULL,
  `host_id` varchar(255) NOT NULL,
  `role` varchar(255) NOT NULL,
  `service` varchar(255) NOT NULL,
  `start_time` datetime DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


-- ------------------------
-- tensorflow
-- ------------------------


-- ------------------------
-- zeppelin
-- ------------------------

CREATE TABLE IF NOT EXISTS `zeppelin_interpreter_confs` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `project_id` INT(11) NOT NULL,
  `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `interpreter_conf` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_id_UNIQUE` (`project_id`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


--
-- Python Dependencies
--

CREATE TABLE IF NOT EXISTS `anaconda_repo` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `url` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `url` (`url`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `python_dep` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `dependency` VARCHAR(128) NOT NULL,
  `version` VARCHAR(128) NOT NULL,
  `repo_id` INT(11) NOT NULL,
  `status` INT(11) NOT NULL,
  `preinstalled` TINYINT(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY (`dependency`, `version`),
  KEY (`status`),
  FOREIGN KEY (`repo_id`) REFERENCES `anaconda_repo` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


CREATE TABLE IF NOT EXISTS `project_pythondeps` (
  `project_id` INT(11) NOT NULL,
  `dep_id` INT(10) NOT NULL,
  PRIMARY KEY (`project_id`, `dep_id`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`dep_id`) REFERENCES `python_dep` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs /*!50100 PARTITION BY KEY (project_id) */;


--
-- Kagent Asynchronous Commands for Conda Operations
--

CREATE TABLE IF NOT EXISTS `conda_commands` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `project_id` INT(11) NOT NULL,
  `user` VARCHAR(52) NOT NULL,
  `op` VARCHAR(52) NOT NULL,
  `proj` VARCHAR(255) NOT NULL,
  `channel_url` VARCHAR(255),
  `arg` VARCHAR(255),
  `lib` VARCHAR(255),
  `version` VARCHAR(52),
  `host_id` INT(11) NOT NULL,
  `status` VARCHAR(52) NOT NULL,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY (`host_id`),
  FOREIGN KEY (`host_id`) REFERENCES `hosts` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


--
-- Jupyter server per project
--

CREATE TABLE IF NOT EXISTS `jupyter_project` (
  `port` INT(11) NOT NULL,
  `hdfs_user_id` int(11) NOT NULL,
  `created` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `last_accessed` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `host_ip` VARCHAR(255) NOT NULL,
  `token` VARCHAR(255) NOT NULL,
  `secret` VARCHAR(64) NOT NULL,
  `pid` BIGINT NOT NULL,
  `project_id` INT(11) NOT NULL,
  PRIMARY KEY (`port`),
  KEY `hdfs_user_idx` (`hdfs_user_id`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
  ) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

--
-- Mapping of jupyter notebook servers to Livy interpreters
--
CREATE TABLE IF NOT EXISTS `jupyter_interpreter` (
  `port` INT(11) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `created` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `last_accessed` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`port`,`name`),
  FOREIGN KEY (`port`) REFERENCES `jupyter_project` (`port`) ON DELETE CASCADE ON UPDATE NO ACTION
  ) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


--
-- Project Devices feature
--

CREATE TABLE IF NOT EXISTS `project_devices`(
  `project_id` INT(11) NOT NULL,
  `device_uuid` VARCHAR(36) NOT NULL,
  `password` VARCHAR(64) NOT NULL,
  `alias` VARCHAR(80) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `state` TINYINT(1) NOT NULL DEFAULT '0',
  `last_logged_in` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`project_id`, `device_uuid`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `project_devices_settings` (
  `project_id` INT(11) NOT NULL,
  `jwt_secret` VARCHAR(128) NOT NULL,
  `jwt_token_duration` INT(11) NOT NULL,
  PRIMARY KEY (`project_id`),
  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;


--
-- Backups for MySQL Cluster
--

CREATE TABLE IF NOT EXISTS `ndb_backup` (
  `backup_id` INT(11) NOT NULL,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`backup_id`)
  ) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

--
-- Dela tables
--
CREATE TABLE IF NOT EXISTS `dela` (
  `id` VARCHAR(200) NOT NULL,
  `did` INT(11) NOT NULL,
  `pid` INT(11) NOT NULL,
  `name` VARCHAR(200) NOT NULL,
  `status` VARCHAR(52) NOT NULL,
  `stream` VARCHAR(200),
  `partners` VARCHAR(200),
  PRIMARY KEY (`id`),
  FOREIGN KEY (`did`) REFERENCES `dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `hopssite_cluster_certs` (
  `cluster_name` varchar(129) NOT NULL,
  `cluster_key` varbinary(7000) DEFAULT NULL,
  `cluster_cert` varbinary(3000) DEFAULT NULL,
  `cert_password` varchar(200) NOT NULL DEFAULT '',
  PRIMARY KEY (`cluster_name`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `cluster_cert` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agent_id` int(11) NOT NULL,
  `common_name` varchar(64) NOT NULL,
  `organization_name` varchar(64) NOT NULL,
  `organizational_unit_name` varchar(64) NOT NULL,
  `serial_number` varchar(45) DEFAULT NULL,
  `registration_status` varchar(45) NOT NULL,
  `validation_key` varchar(128) DEFAULT NULL,
  `validation_key_date` timestamp NULL DEFAULT NULL,
  `registration_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `organization_name` (`organization_name`,`organizational_unit_name`),
  UNIQUE KEY `serial_number` (`serial_number`),
  KEY `agent_id` (`agent_id`),
  FOREIGN KEY (`agent_id`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
--
-- End Dela tables
--

-- VIEWS --------------
-- ---------------------

CREATE OR REPLACE VIEW `users_groups` AS
    select `u`.`username` AS `username`,
    `u`.`password` AS `password`,
    `u`.`secret` AS `secret`,
    `u`.`email` AS `email`,
    `g`.`group_name` AS `group_name`
    from
    ((`user_group` `ug` join `users` `u` on((`u`.`uid` = `ug`.`uid`))) join `bbc_group` `g` on((`g`.`gid` = `ug`.`gid`)));



CREATE OR REPLACE VIEW `hops_users` AS select concat(`pt`.`team_member`,'__',`p`.`projectname`) AS `project_user` from ((`project` `p` join `project_team` `pt`) join `ssh_keys` `sk`) where `pt`.`team_member` in (select `u`.`email` from (`users` `u` join `ssh_keys` `s`) where (`u`.`uid` = `s`.`uid`));

--
-- LDAP tables
--
CREATE TABLE IF NOT EXISTS `ldap_user` (
  `entry_uuid` VARCHAR(128) NOT NULL,
  `auth_key` VARCHAR(64) NOT NULL,
  `uid` INT(11) NOT NULL,
  PRIMARY KEY (`entry_uuid`),
  UNIQUE KEY `uid_UNIQUE` (`uid`),
  FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

