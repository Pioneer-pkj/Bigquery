-- SCD2 in one MERGE
MERGE `dw.dim_customer` T
USING (
  WITH src AS (
    SELECT
      s.customer_id,
      s.customer_name,
      s.customer_status,
      s.load_ts,
      -- Create a compact hash of the tracked attributes
      TO_HEX(MD5(CONCAT(IFNULL(s.customer_name,''), '|', IFNULL(s.customer_status,'')))) AS new_hash
    FROM `stg.stg_customer` s
  ),
  curr AS (
    -- Current active rows in the dimension
    SELECT
      d.customer_id,
      d.attr_hash AS curr_hash
    FROM `dw.dim_customer` d
    WHERE d.is_current = TRUE
  ),
  changes AS (
    -- Rows that are new (no current) OR changed (hash differs)
    SELECT
      src.*,
      curr.curr_hash
    FROM src
    LEFT JOIN curr
      ON curr.customer_id = src.customer_id
    WHERE curr.curr_hash IS NULL                       -- new key
       OR curr.curr_hash != src.new_hash               -- changed attributes
  ),
  actions AS (
    -- 1) For changed existing keys: emit "expire" action to close current row
    SELECT
      c.customer_id,
      c.customer_name,
      c.customer_status,
      c.new_hash,
      c.load_ts,
      'expire' AS action
    FROM changes c
    WHERE c.curr_hash IS NOT NULL

    UNION ALL

    -- 2) For both brand-new and changed keys: emit "insert" action for the new version
    SELECT
      c.customer_id,
      c.customer_name,
      c.customer_status,
      c.new_hash,
      c.load_ts,
      'insert' AS action
    FROM changes c
  )
  SELECT * FROM actions
) S
-- Important: Match only when the action is "expire" so UPDATE hits the current row.
ON  T.customer_id = S.customer_id
AND T.is_current = TRUE
AND S.action = 'expire'

-- Close the current row (only for "expire" actions)
WHEN MATCHED THEN
  UPDATE SET
    valid_to   = S.load_ts,
    is_current = FALSE

-- Insert new version (fires for "insert" actions because ON won't match them)
WHEN NOT MATCHED AND S.action = 'insert' THEN
  INSERT (
    surrogate_key,
    customer_id,
    customer_name,
    customer_status,
    attr_hash,
    valid_from,
    valid_to,
    is_current
  )
  VALUES (
    GENERATE_UUID(),
    S.customer_id,
    S.customer_name,
    S.customer_status,
    S.new_hash,
    S.load_ts,
    TIMESTAMP '9999-12-31 00:00:00',
    TRUE
  );
