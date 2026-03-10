
CREATE TABLE IF NOT EXISTS `dw.dim_customer` (
  surrogate_key STRING DEFAULT GENERATE_UUID(),
  customer_id   STRING,                -- business key
  customer_name STRING,
  customer_status STRING,
  attr_hash     STRING,                -- change detection
  valid_from    TIMESTAMP,
  valid_to      TIMESTAMP,
  is_current    BOOL
)
PARTITION BY DATE(valid_from)
CLUSTER BY customer_id;



CREATE TABLE IF NOT EXISTS `stg.stg_customer` (
  customer_id   STRING,
  customer_name STRING,
  customer_status STRING,
  load_ts       TIMESTAMP              -- "as of" time for this batch
);


--- sample records to dump in dim_cutomer_table

INSERT INTO `dw.dim_customer` (
  surrogate_key,
  customer_id,
  customer_name,
  customer_status,
  attr_hash,
  valid_from,
  valid_to,
  is_current
)
VALUES
-- 1
(GENERATE_UUID(), 'C001', 'Alice Johnson', 'Active',
 TO_HEX(MD5('Alice Johnson|Active')),
 TIMESTAMP '2026-02-01 09:00:00', TIMESTAMP '9999-12-31 00:00:00', TRUE),

-- 2
(GENERATE_UUID(), 'C002', 'Bob Miller', 'Active',
 TO_HEX(MD5('Bob Miller|Active')),
 TIMESTAMP '2026-02-03 10:30:00', TIMESTAMP '9999-12-31 00:00:00', TRUE),

-- 3
(GENERATE_UUID(), 'C003', 'Charlie Singh', 'Inactive',
 TO_HEX(MD5('Charlie Singh|Inactive')),
 TIMESTAMP '2026-02-05 11:15:00', TIMESTAMP '9999-12-31 00:00:00', TRUE),

-- 4
(GENERATE_UUID(), 'C004', 'Diana Kapoor', 'Active',
 TO_HEX(MD5('Diana Kapoor|Active')),
 TIMESTAMP '2026-02-06 14:00:00', TIMESTAMP '9999-12-31 00:00:00', TRUE),

-- 5
(GENERATE_UUID(), 'C005', 'Ethan Zhao', 'Suspended',
 TO_HEX(MD5('Ethan Zhao|Suspended')),
 TIMESTAMP '2026-02-07 08:45:00', TIMESTAMP '9999-12-31 00:00:00', TRUE),

-- 6
(GENERATE_UUID(), 'C006', 'Fatima Noor', 'Active',
 TO_HEX(MD5('Fatima Noor|Active')),
 TIMESTAMP '2026-02-08 13:20:00', TIMESTAMP '9999-12-31 00:00:00', TRUE),

-- 7
(GENERATE_UUID(), 'C007', 'George Peters', 'Active',
 TO_HEX(MD5('George Peters|Active')),
 TIMESTAMP '2026-02-10 16:40:00', TIMESTAMP '9999-12-31 00:00:00', TRUE),

-- 8
(GENERATE_UUID(), 'C008', 'Hina Malhotra', 'Inactive',
 TO_HEX(MD5('Hina Malhotra|Inactive')),
 TIMESTAMP '2026-02-12 12:10:00', TIMESTAMP '9999-12-31 00:00:00', TRUE),

-- 9
(GENERATE_UUID(), 'C009', 'Ivan Rodriguez', 'Active',
 TO_HEX(MD5('Ivan Rodriguez|Active')),
 TIMESTAMP '2026-02-15 07:55:00', TIMESTAMP '9999-12-31 00:00:00', TRUE),

-- 10
(GENERATE_UUID(), 'C010', 'Julia Fernandes', 'Active',
 TO_HEX(MD5('Julia Fernandes|Active')),
 TIMESTAMP '2026-02-18 18:25:00', TIMESTAMP '9999-12-31 00:00:00', TRUE);


-- sampled to dump records in stg_customer_table
INSERT INTO `stg.stg_customer`
(customer_id, customer_name, customer_status, load_ts)
VALUES
('C001', 'Alice A.', 'Active', TIMESTAMP '2026-03-09 10:00:00'),
('C002', 'Bob',      'Active', TIMESTAMP '2026-03-09 10:00:00');
``
