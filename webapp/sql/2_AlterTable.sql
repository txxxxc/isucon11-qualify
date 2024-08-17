ALTER TABLE `isu_condition` ADD COLUMN `condition_level` VARCHAR(255) GENERATED ALWAYS AS ((
    CASE
      WHEN LENGTH(`condition`) = 50 THEN 'info'
      WHEN LENGTH(`condition`) in (48, 49) THEN 'warning'
      WHEN LENGTH(`condition`) = 47 THEN 'critical'
      ELSE 'normal'
    END
  )) STORED;

CREATE INDEX `idx_isu_condition_jia_isu_uuid_timestamp_desc_condition_level` ON `isu_condition` (`jia_isu_uuid`, `timestamp` DESC, `condition_level`);