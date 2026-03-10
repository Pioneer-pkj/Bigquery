-- ==============================
-- author: pankaj.ipar
-- date: 03-03-2026
-- ==============================

-- ==============================================
-- Batch archival calls
-- Fortinet + Meraki + Viptel + VeloCloud + GoGo
-- ==============================================


-- ---------- Global parameters ----------
BEGIN
DECLARE in_project_id STRING DEFAULT 'cto-tinaa-apps-svcs-np-46141';
DECLARE in_dataset_fn STRING DEFAULT 'fortinet_stats';
DECLARE in_dataset_mk STRING DEFAULT 'meraki_stats';
DECLARE in_dataset_vl STRING DEFAULT 'velo_stats';
DECLARE in_dataset_vp STRING DEFAULT 'vip_stats';
DECLARE in_dataset_gg STRING DEFAULT 'goco_stats';
DECLARE in_bucket_fn STRING DEFAULT 'spog-fortinet-bq-archive-dev';
DECLARE in_bucket_mk STRING DEFAULT 'spog-meraki-bq-archive-dev';
DECLARE in_bucket_vl STRING DEFAULT 'spog-velo-bq-archive-dev';
DECLARE in_bucket_vp STRING DEFAULT 'spog-vip-bq-archive-dev';
DECLARE in_bucket_gg STRING DEFAULT 'spog-goco-bq-archive-dev';
DECLARE in_bucket_prefix_fn STRING DEFAULT 'fortinet';
DECLARE in_bucket_prefix_mk STRING DEFAULT 'meraki';
DECLARE in_bucket_prefix_vl STRING DEFAULT 'velo';
DECLARE in_bucket_prefix_vp STRING DEFAULT 'vip';
DECLARE in_bucket_prefix_gg STRING DEFAULT 'goco';
DECLARE in_interval INT64 DEFAULT 1;
DECLARE in_period STRING DEFAULT 'MONTH';
DECLARE in_header  BOOL     DEFAULT TRUE;
DECLARE in_delimiter    STRING   DEFAULT ',';
DECLARE in_overwrite    BOOL     DEFAULT TRUE;

-- ---------- Vendor specific Table lists ----------
--           --- Fortnet table -----
DECLARE fortinet_tables ARRAY<STRING> DEFAULT [

 'fortinet_edge_poll',
  'fortinet_license_poll',
  'fortinet_url_polll'

];

-------------- Meraki table -----
DECLARE meraki_table ARRAY<STRING> DEFAULT [

  'meraki_edge_poll',
  'meraki_license_poll',
  'meraki_vpn_poll',
  'meraki_url_poll'

];

-------------Velo tables -------
DECLARE velo_tables ARRAY<STRING> DEFAULT [

  'velo_edge_poll',
  'velo_license_poll',
  'velo_pgw_poll',
  'velo_url_poll'


];

-------------Vip tables -------
DECLARE vip_tables ARRAY<STRING> DEFAULT[

  'vip_edge_poll',
  'vip_license_poll',
  'vip_gw_poll',
  'vip_url_poll',
  'vip_certificate_poll',
  'vip_controller_poll',
  'vip_health_poll'

];



-- ----------GoGo tables-------
DECLARE goco_tables ARRAY<STRING> DEFAULT [

  'goco_edge_poll',
  'goco_license_poll',
  'goco_pgw_poll',
  'goco_url_poll'


];


-- 1. call stored proc for fortinet tables & peform export
-- 2. delete exported records for fortinet tables 

FOR t IN (SELECT in_table_name FROM UNNEST(fortinet_tables) as in_table_name)
  DO
    CALL `cto-tinaa-apps-svcs-np-461414.spog_archival_data_dev.spog_archived_data_dev`(
              in_project_id, in_dataset_fn, t.in_table_name, in_bucket_fn, in_bucket_prefix_fn, in_interval, in_period, in_header, in_delimiter, in_overwrite);

    EXECUTE IMMEDIATE FORMAT("""DELETE FROM %s.%s.%s 
      WHERE DATE(timeStamp) < DATE_SUB(CURRENT_DATE(), INTERVAL %d %s)""",  in_project_id, in_dataset_fn, t.in_table_name, in_interval, in_period);
END FOR;



-- 1. call stored proc for meraki tables & peform export
-- 2. delete exported records for meraki tables 

FOR t IN (SELECT in_table_name FROM UNNEST(meraki_tables) as in_table_name)
  DO
   CALL `cto-tinaa-apps-svcs-np-461414.spog_archival_data_dev.spog_archived_data_dev`(
              in_project_id, in_dataset_mk, t.in_table_name, in_bucket_mk, in_bucket_prefix_mk, in_interval, in_period, in_header, in_delimiter, in_overwrite);

    EXECUTE IMMEDIATE FORMAT("""DELETE FROM %s.%s.%s 
      WHERE DATE(timeStamp) < DATE_SUB(CURRENT_DATE(), INTERVAL %d %s)""",  in_project_id, in_dataset_mk, t.in_table_name, in_interval, in_period);

END FOR;



-- 1. call stored proc for velo tables & peform export
-- 2. delete exported records for velo tables 

FOR t IN (SELECT in_table_name FROM UNNEST(velo_tables) as in_table_name)
  DO
   CALL `cto-tinaa-apps-svcs-np-461414.spog_archival_data_dev.spog_archived_data_dev`(
              in_project_id, in_dataset_vl, t.in_table_name, in_bucket_vl, in_bucket_prefix_vl, in_interval, in_period, in_header, in_delimiter, in_overwrite);

    EXECUTE IMMEDIATE FORMAT("""DELETE FROM %s.%s.%s 
      WHERE DATE(timeStamp) < DATE_SUB(CURRENT_DATE(), INTERVAL %d %s)""",  in_project_id, in_dataset_vl, t.in_table_name, in_interval, in_period);

END FOR;




-- 1. call stored proc for vip tables & peform export
-- 2. delete exported records for vip tables 

FOR t IN (SELECT in_table_name FROM UNNEST(vip_tables) as in_table_name)
  DO
   CALL `cto-tinaa-apps-svcs-np-461414.spog_archival_data_dev.spog_archived_data_dev`(
              in_project_id, in_dataset_vp, t.in_table_name, in_bucket_vp, in_bucket_prefix_vp, in_interval, in_period, in_header, in_delimiter, in_overwrite);

    EXECUTE IMMEDIATE FORMAT("""DELETE FROM %s.%s.%s 
      WHERE DATE(timeStamp) < DATE_SUB(CURRENT_DATE(), INTERVAL %d %s)""",  in_project_id, in_dataset_vp, t.in_table_name, in_interval, in_period);

END FOR;




-- 1. call stored proc for goog tables & peform export
-- 2. delete exported records for gogo tables 

FOR t IN (SELECT in_table_name FROM UNNEST(goco_tables) as in_table_name)
  DO
   CALL `cto-tinaa-apps-svcs-np-461414.spog_archival_data_dev.spog_archived_data_dev`(
              in_project_id, in_dataset_gg, t.in_table_name, in_bucket_gg, in_bucket_prefix_gg, in_interval, in_period, in_header, in_delimiter, in_overwrite);

    EXECUTE IMMEDIATE FORMAT("""DELETE FROM %s.%s.%s 
      WHERE DATE(timeStamp) < DATE_SUB(CURRENT_DATE(), INTERVAL %d %s)""",  in_project_id, in_dataset_gg, t.in_table_name, in_interval, in_period);

END FOR;



END;
