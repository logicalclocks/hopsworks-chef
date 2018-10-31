-- MySQL dump 10.13  Distrib 5.7.23-ndb-7.6.7, for linux-glibc2.12 (x86_64)
--
-- Host: localhost    Database: hopsworks
-- ------------------------------------------------------
-- Server version	5.7.23-ndb-7.6.7-cluster-gpl

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `flyway_schema_history`
--

DROP TABLE IF EXISTS `flyway_schema_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flyway_schema_history` (
  `installed_rank` int(11) NOT NULL,
  `version` varchar(50) DEFAULT NULL,
  `description` varchar(200) NOT NULL,
  `type` varchar(20) NOT NULL,
  `script` varchar(1000) NOT NULL,
  `checksum` int(11) DEFAULT NULL,
  `installed_by` varchar(100) NOT NULL,
  `installed_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `execution_time` int(11) NOT NULL,
  `success` tinyint(1) NOT NULL,
  PRIMARY KEY (`installed_rank`),
  KEY `flyway_schema_history_s_idx` (`success`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flyway_schema_history`
--

LOCK TABLES `flyway_schema_history` WRITE;
/*!40000 ALTER TABLE `flyway_schema_history` DISABLE KEYS */;
INSERT INTO `flyway_schema_history` VALUES (5,'0.3.0','hopsworks','SQL','V0.3.0__hopsworks.sql',0,'kthfs','2018-10-17 21:16:11',2,1),(7,'0.4.1','hopsworks','SQL','V0.4.1__hopsworks.sql',0,'kthfs','2018-10-17 21:16:12',0,1),(3,'0.1.0','hopsworks','SQL','V0.1.0__hopsworks.sql',0,'kthfs','2018-10-17 21:16:11',2,1),(9,'0.5.0','hopsworks','SQL','V0.5.0__hopsworks.sql',732704847,'kthfs','2018-10-17 21:16:15',2747,1),(1,'0.0.1','First Hopsworks migration','BASELINE','First Hopsworks migration',NULL,'kthfs','2018-10-17 21:16:02',0,1),(6,'0.4.0','hopsworks','SQL','V0.4.0__hopsworks.sql',-1092590637,'kthfs','2018-10-17 21:16:12',1281,1),(2,'0.0.2','initial tables','SQL','V0.0.2__initial_tables.sql',2097514569,'kthfs','2018-10-17 21:16:11',7389,1),(4,'0.2.0','hopsworks','SQL','V0.2.0__hopsworks.sql',0,'kthfs','2018-10-17 21:16:11',0,1),(8,'0.4.2','hopsworks','SQL','V0.4.2__hopsworks.sql',2066712169,'kthfs','2018-10-17 21:16:12',411,1);
/*!40000 ALTER TABLE `flyway_schema_history` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-10-31 13:48:57
