-- FSTORE-1047
CREATE TABLE IF NOT EXISTS `embedding` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `feature_group_id` int(11) NOT NULL,
    `col_prefix` varchar(255) NULL,
    `vector_db_index_name` varchar(255) NOT NULL,
    PRIMARY KEY (`id`),
    KEY `feature_group_id` (`feature_group_id`),
    CONSTRAINT `feature_group_embedding_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
    ) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `embedding_feature` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `embedding_id` int(11) NOT NULL,
    `name` varchar(255) NOT NULL,
    `dimension` int NOT NULL,
    `similarity_function_type` varchar(255) NOT NULL,
    PRIMARY KEY (`id`),
    KEY `embedding_id` (`embedding_id`),
    CONSTRAINT `embedding_feature_fk` FOREIGN KEY (`embedding_id`) REFERENCES `embedding` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
    ) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- FSTORE-1119
DELIMITER //

DROP PROCEDURE IF EXISTS add_group_column_to_offset_tables//

CREATE PROCEDURE add_group_column_to_offset_tables()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE db_name VARCHAR(255);

    DECLARE db_cursor CURSOR FOR
SELECT name FROM `hopsworks`.`feature_store`;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN db_cursor;

read_loop: LOOP
        FETCH db_cursor INTO db_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET @alter_query := CONCAT(
            'ALTER TABLE `', db_name, '`.`kafka_offsets` ADD COLUMN `consumer_group` VARCHAR(255) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL DEFAULT ''RONDB'''
        );

        SET @exists := (
            SELECT COUNT(*)
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_SCHEMA = db_name AND TABLE_NAME = 'kafka_offsets'
        );

        IF @exists > 0 THEN
            PREPARE stmt FROM @alter_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        END IF;
END LOOP;

CLOSE db_cursor;
END //

DELIMITER ;

CALL add_group_column_to_offset_tables();