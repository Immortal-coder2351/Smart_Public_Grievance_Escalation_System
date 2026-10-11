USE smart_grievance;

SET @priority_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'complaints'
      AND COLUMN_NAME = 'priority'
);

SET @sql = IF(
    @priority_exists = 0,
    "ALTER TABLE complaints ADD COLUMN priority ENUM('HIGH','MEDIUM','LOW') NOT NULL DEFAULT 'MEDIUM' AFTER category",
    "SELECT 1"
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Existing complaints receive MEDIUM priority when the column is first added.
