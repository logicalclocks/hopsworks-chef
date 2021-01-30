DROP TABLE `address`;
DROP TABLE `organization`;
DROP TABLE `authorized_sshkeys`;
DROP TABLE `ssh_keys`;

ALTER TABLE `users` DROP COLUMN `security_question`, DROP COLUMN `security_answer`, DROP COLUMN `mobile`;