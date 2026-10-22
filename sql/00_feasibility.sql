-- P0: three read-only GoogleSQL statements. Run ONE statement at a time.
-- Initial SQL drafted with ChatGPT; Codex execution is recorded in the evidence file.
-- Verified execution project: seis-732-david; dataset/query location: US.
-- Q1 confirmed storms_2024; Q2 confirmed the required STRING/DATETIME fields.
-- On reruns, confirm inventory and schema sequentially before proceeding.
-- Inspect the validator estimate before each run. Set Maximum bytes billed to
-- 1073741824 (1 GiB), or a lower documented course limit; stop if exceeded.
-- A state filter or LIMIT does not guarantee a smaller scan.
-- No source rows or individual IDs are returned. Save only the aggregate outputs.

-- Q1: discover available annual objects; record ONE selected table.
SELECT table_name, table_type
FROM `bigquery-public-data.noaa_historic_severe_storms.INFORMATION_SCHEMA.TABLES`
WHERE REGEXP_CONTAINS(table_name, r'^storms_[0-9]{4}$')
ORDER BY table_name DESC;

-- Q2: inspect the selected table's analytical fields and grain context.
SELECT column_name, data_type, is_nullable
FROM `bigquery-public-data.noaa_historic_severe_storms.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'storms_2024'
  AND column_name IN (
    'event_id', 'state_fips_code', 'cz_type', 'cz_fips_code', 'cz_name',
    'event_type', 'event_begin_time', 'event_end_time', 'location_index'
  )
ORDER BY ordinal_position;

-- Q3: one aggregate result row. No damage sums or event deduplication is performed.
-- MIN/MAX reflect observed coverage, not proven completeness.
-- Begin/end DATETIME values are civil source times, not proven UTC timestamps.
-- Repeated/conflicting IDs are tested only inside the target subset and only
-- for county code, hazard, and begin time. P1 must establish the final grain/key.
WITH normalized AS (
  SELECT
    NULLIF(TRIM(CAST(event_id AS STRING)), '') AS event_id,
    SAFE_CAST(state_fips_code AS INT64) AS state_fips,
    NULLIF(UPPER(TRIM(cz_type)), '') AS county_or_zone,
    NULLIF(TRIM(CAST(cz_fips_code AS STRING)), '') AS county_code,
    NULLIF(TRIM(cz_name), '') AS county_name,
    NULLIF(LOWER(TRIM(event_type)), '') AS hazard,
    event_begin_time,
    event_end_time
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_2024`
), scoped AS (
  SELECT *,
    state_fips = 27 AND county_or_zone = 'C'
      AND hazard IN ('hail', 'thunderstorm wind', 'tornado', 'flash flood') AS is_target
  FROM normalized
), profile AS (
  SELECT
    COUNT(*) AS source_rows,
    COUNT(DISTINCT event_id) AS source_distinct_event_ids,
    COUNTIF(event_id IS NULL) AS source_missing_event_id_rows,
    MIN(event_begin_time) AS source_earliest_begin,
    MAX(event_begin_time) AS source_latest_begin,
    COUNTIF(state_fips IS NULL OR county_or_zone IS NULL OR hazard IS NULL)
      AS source_rows_missing_scope_fields,
    COUNTIF(is_target) AS target_rows,
    COUNT(DISTINCT IF(is_target, event_id, NULL)) AS target_distinct_event_ids,
    COUNTIF(is_target AND event_id IS NULL) AS target_missing_event_id_rows,
    MIN(IF(is_target, event_begin_time, NULL)) AS target_earliest_begin,
    MAX(IF(is_target, event_begin_time, NULL)) AS target_latest_begin,
    MAX(IF(is_target, event_end_time, NULL)) AS target_latest_end,
    COUNTIF(is_target AND event_begin_time IS NULL) AS target_missing_begin_rows,
    COUNTIF(is_target AND event_end_time IS NULL) AS target_missing_end_rows,
    COUNTIF(is_target AND event_end_time < event_begin_time) AS target_end_before_begin_rows,
    COUNTIF(is_target AND county_code IS NULL) AS target_missing_county_code_rows,
    COUNTIF(is_target AND county_name IS NULL) AS target_missing_county_name_rows,
    COUNT(DISTINCT IF(is_target, county_code, NULL)) AS target_distinct_county_codes,
    COUNT(DISTINCT IF(is_target, hazard, NULL)) AS target_distinct_hazards,
    COUNT(DISTINCT IF(is_target, EXTRACT(MONTH FROM event_begin_time), NULL))
      AS target_distinct_months
  FROM scoped
), target_events AS (
  SELECT event_id,
    COUNT(*) AS event_source_rows,
    COUNT(DISTINCT TO_JSON_STRING(STRUCT(
      county_code, hazard, event_begin_time
    ))) AS attribute_versions
  FROM scoped
  WHERE is_target AND event_id IS NOT NULL
  GROUP BY event_id
), event_checks AS (
  SELECT
    COUNTIF(event_source_rows > 1) AS target_repeated_event_ids,
    COUNTIF(attribute_versions > 1) AS target_conflicting_event_ids
  FROM target_events
)
SELECT profile.*, event_checks.*
FROM profile CROSS JOIN event_checks;
