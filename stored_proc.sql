-- stored proc to export data in gcs bucket based on in_interval & in_period

CREATE OR REPLACE PROCEDURE `cto-tinaa-apps-svcs-np-461414.spog_archival_data_dev.spog_archived_data_dev`( 
                        in_project_id STRING,   --project id,
                        in_dataset_id STRING,   --dataset_id,
                        in_table_name STRING,   --table_name,
                        in_gcs_bucket STRING,   -- archieval bucket name,
                        in_gcs_prefix STRING,   -- gcs_prefix,
                        in_interval INT64,        -- Interval,
                        in_period STRING,        -- period ex month, year, day,
                        in_header BOOL,         -- set to true,
                        in_delimiter STRING,    -- delimiter ',',
                        in_overwrite BOOL      -- overwrite file if exists set to true
                        )

BEGIN
DECLARE id STRING;
DECLARE ts STRING DEFAULT FORMAT_TIMESTAMP('%Y%m%dT%H%M%S', CURRENT_TIMESTAMP());
DECLARE uri STRING DEFAULT FORMAT('gs://%s/%s/%s_%s_*.csv.gz', in_gcs_bucket, in_gcs_prefix, in_table_name, ts);

EXECUTE IMMEDIATE FORMAT("""
    EXPORT DATA OPTIONS(
uri = @uri,
format='CSV',
compression='GZIP',
header=%t,
field_delimiter=@delim,
overwrite=%t
)
AS 
(
SELECT * FROM `%s.%s.%s`
WHERE DATE(TIMESTAMP) < DATE_SUB(CURRENT_DATE(), INTERVAL %d %s)
ORDER BY timeStamp DESC
)

""", in_header, in_overwrite, in_project_id, in_dataset_id, in_table_name, in_interval, in_period)
USING uri AS uri, in_delimiter as delim;
END;
