ALTER TABLE `hopsworks`.`jobs`
DROP INDEX `name_project_idx` ,
ADD UNIQUE INDEX `name_idx` (`name` ASC);
