" ------------------------------------------------------------------------------------
" Script: load_demo_data.abap
" Purpose: Load demo data into ZTRAVEL_TAB and ZTRAVEL_TAB_D
" Author: Daniele
" ------------------------------------------------------------------------------------

DELETE FROM ztravel_tab.
DELETE FROM ztravel_tab_d.

DATA:
  group_id   TYPE string VALUE '###',
  attachment TYPE /dmo/attachment,
  file_name  TYPE /dmo/filename,
  mime_type  TYPE /dmo/mime_type.

INSERT ztravel_tab FROM (
    SELECT
      travel~travel_id        AS travel_id,
      travel~agency_id        AS agency_id,
      travel~customer_id      AS customer_id,
      travel~begin_date       AS begin_date,
      travel~end_date         AS end_date,
      travel~booking_fee      AS booking_fee,
      travel~total_price      AS total_price,
      travel~currency_code    AS currency_code,
      travel~description      AS description,
      CASE travel~status
        WHEN 'N' THEN 'O'
        WHEN 'P' THEN 'O'
        WHEN 'B' THEN 'A'
        ELSE 'X'
      END                     AS overall_status,
      @attachment             AS attachment,
      @mime_type              AS mime_type,
      @file_name              AS file_name,
      travel~createdby        AS created_by,
      travel~createdat        AS created_at,
      travel~lastchangedby    AS last_changed_by,
      travel~lastchangedat    AS last_changed_at,
      travel~lastchangedat    AS local_last_changed_at
      FROM /dmo/travel AS travel
      WHERE travel_id IS NOT INITIAL
      ORDER BY travel_id
      UP TO 10 ROWS
).

COMMIT WORK.
