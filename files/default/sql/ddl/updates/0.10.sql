--
--  Maggy Driver Service Lookup Table in Hopsworks
--
CREATE TABLE IF NOT EXISTS `maggy_driver` (
  `app_id` char(30) COLLATE latin1_general_cs NOT NULL,
  `host_ip` varchar(128) COLLATE latin1_general_cs NOT NULL,
  `port` int(11) NOT NULL,
  `secret` varchar(128) COLLATE latin1_general_cs NOT NULL,
  `created`    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`app_id`)
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

