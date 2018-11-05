CREATE TABLE IF NOT EXISTS `remote_material_references` (
       `username` VARCHAR(128) NOT NULL,
       `path` VARCHAR(255) NOT NULL,
       `references` INT(11) NOT NULL DEFAULT 0,
       `lock` INT(1) NOT NULL DEFAULT 0,
       `lock_id` VARCHAR(30) NOT NULL DEFAULT "",
       PRIMARY KEY (`username`, `path`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;


ALTER TABLE python_dep ADD COLUMN `install_type` INT(11) NOT NULL;
ALTER TABLE python_dep ADD COLUMN `machine_type` INT(11) NOT NULL;
ALTER TABLE python_dep DROP INDEX dependency;
ALTER TABLE python_dep ADD UNIQUE KEY (`dependency`, `version`, `install_type`, `repo_id`, `machine_type`);


ALTER TABLE conda_commands ADD COLUMN `install_type` VARCHAR(52);
ALTER TABLE conda_commands ADD COLUMN `machine_type` VARCHAR(52);
