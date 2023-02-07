--
-- Table structure for table `shared_topics`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shared_topics` (
                                 `topic_name` varchar(255) COLLATE latin1_general_cs NOT NULL,
                                 `project_id` int(11) NOT NULL,
                                 `owner_id` int(11) NOT NULL,
                                 `accepted` tinyint(1) NOT NULL DEFAULT '0',
                                 PRIMARY KEY (`project_id`,`topic_name`),
                                 KEY `topic_idx` (`topic_name`,`owner_id`),
                                 CONSTRAINT `topic_idx_shared` FOREIGN KEY (`topic_name`,`owner_id`) REFERENCES `project_topics` (`topic_name`,`project_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs
    /*!50100 PARTITION BY KEY (topic_name) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_acls`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `topic_acls` (
                              `id` int(11) NOT NULL AUTO_INCREMENT,
                              `topic_name` varchar(255) COLLATE latin1_general_cs NOT NULL,
                              `project_id` int(11) NOT NULL,
                              `username` varchar(150) COLLATE latin1_general_cs NOT NULL,
                              `principal` varchar(170) COLLATE latin1_general_cs NOT NULL,
                              `permission_type` varchar(255) COLLATE latin1_general_cs NOT NULL,
                              `operation_type` varchar(255) COLLATE latin1_general_cs NOT NULL,
                              `host` varchar(255) COLLATE latin1_general_cs NOT NULL,
                              `role` varchar(255) COLLATE latin1_general_cs NOT NULL,
                              PRIMARY KEY (`id`),
                              KEY `username` (`username`),
                              KEY `topic_idx` (`topic_name`,`project_id`),
                              CONSTRAINT `FK_262_338` FOREIGN KEY (`username`) REFERENCES `users` (`email`) ON DELETE NO ACTION ON UPDATE NO ACTION,
                              CONSTRAINT `topic_idx_topic_acls` FOREIGN KEY (`topic_name`,`project_id`) REFERENCES `project_topics` (`topic_name`,`project_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

UPDATE `project_team`
SET team_role = 'Data scientist'
WHERE team_member = 'serving@hopsworks.se';
