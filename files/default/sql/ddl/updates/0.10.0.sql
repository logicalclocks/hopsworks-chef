ALTER TABLE jupyter_project CHANGE `last_accessed` `expires` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;

DROP TABLE IF EXISTS  `hopsworks`.`projectgenericuser_certs`;
DROP TABLE IF EXISTS  `hopsworks`.`zeppelin_interpreter_confs`;

-- Remove Zeppelin as service from existing projects
DELETE FROM `hopsworks`.`project_services` where `service`='ZEPPELIN';