DROP VIEW `hops_users`;

DROP TABLE `address`;
DROP TABLE `organization`;
DROP TABLE `authorized_sshkeys`;
DROP TABLE `ssh_keys`;

ALTER TABLE `users` DROP COLUMN `security_question`, DROP COLUMN `security_answer`, DROP COLUMN `mobile`;

ALTER TABLE `hopsworks`.`feature_store_tag` DROP COLUMN `type`;
ALTER TABLE `hopsworks`.`feature_store_tag` ADD COLUMN `tag_schema` VARCHAR(13000) NOT NULL DEFAULT '{"type":"string"}';
