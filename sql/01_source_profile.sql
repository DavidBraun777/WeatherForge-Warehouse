-- P1: read-only GoogleSQL. Run ONE statement at a time; return aggregates only.
-- Execution project: seis-732-david. Dataset/query location: US.
-- Recheck the source schema and inspect the validator estimate before execution.
-- Set Maximum bytes billed to 1073741824 (1 GiB), or a lower course limit.
-- This comment does not configure the job: set the limit in the client/UI.
-- Stop if the estimate exceeds the limit. Filters do not guarantee less scanning.
-- No BigQuery execution of this file is claimed in P1.
--
-- Proposed fact: one reported event per successful source capture. Physical key:
-- (snapshot_id, event_id), with the fixed annual source table recorded by snapshot.
-- Repeated source rows may be event-location observations; do not discard them
-- from Raw or select arbitrary county/hazard/date values to conceal conflicts.
-- After validation, each capture's fact total must equal that capture's eligible
-- distinct-event total. It is NOT required to remain 809 after source revisions.

-- Q1: focused reproduction of the scoped P0 Q3 grain checks.
-- The normalization, scope, and attribute-conflict expression below match
-- sql/00_feasibility.sql Q3. The annual table supplies the 2024 scope; adding an
-- event-date filter here would change the original check. Q2 diagnoses dates.
--
-- Auditable mapping: Q1 output -> P0 Q3 output -> recorded October 21, 2026 value.
-- scoped_source_rows                -> target_rows                       -> 885
-- distinct_event_ids                -> target_distinct_event_ids         -> 809
-- rows_with_missing_event_id        -> target_missing_event_id_rows      -> 0
-- repeated_event_id_groups          -> target_repeated_event_ids         -> 39
-- conflicting_event_id_groups       -> target_conflicting_event_ids      -> 0
-- rows_with_missing_county_code     -> target_missing_county_code_rows   -> 0
-- rows_with_missing_begin_time      -> target_missing_begin_rows         -> 0
-- These values come from evidence/p0-feasibility-results.md, not a run of Q1.
-- Expected event-level input would have zero missing IDs and zero repeated ID
-- groups. The 39 observed repeated groups qualify that candidate: the source is
-- not already one row per event. Zero checked assignment conflicts supports a
-- validated event-level projection; it does not establish source-location keys.
WITH normalized AS (
  SELECT
    NULLIF(TRIM(CAST(event_id AS STRING)), '') AS event_id,
    SAFE_CAST(state_fips_code AS INT64) AS state_fips,
    NULLIF(UPPER(TRIM(cz_type)), '') AS county_or_zone,
    NULLIF(TRIM(CAST(cz_fips_code AS STRING)), '') AS county_code,
    NULLIF(LOWER(TRIM(event_type)), '') AS hazard,
    event_begin_time
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_2024`
), target AS (
  SELECT *
  FROM normalized
  WHERE state_fips = 27
    AND county_or_zone = 'C'
    AND hazard IN ('hail', 'thunderstorm wind', 'tornado', 'flash flood')
), profile AS (
  SELECT
    COUNT(*) AS scoped_source_rows,
    COUNT(DISTINCT event_id) AS distinct_event_ids,
    COUNTIF(event_id IS NULL) AS rows_with_missing_event_id,
    COUNTIF(county_code IS NULL) AS rows_with_missing_county_code,
    COUNTIF(event_begin_time IS NULL) AS rows_with_missing_begin_time
  FROM target
), event_groups AS (
  SELECT
    event_id,
    COUNT(*) AS rows_per_event,
    COUNT(DISTINCT TO_JSON_STRING(STRUCT(
      county_code, hazard, event_begin_time
    ))) AS assignment_versions
  FROM target
  WHERE event_id IS NOT NULL
  GROUP BY event_id
), event_checks AS (
  SELECT
    COUNTIF(rows_per_event > 1) AS repeated_event_id_groups,
    COUNTIF(assignment_versions > 1) AS conflicting_event_id_groups
  FROM event_groups
)
SELECT
  profile.scoped_source_rows,
  profile.distinct_event_ids,
  profile.rows_with_missing_event_id,
  event_checks.repeated_event_id_groups,
  event_checks.conflicting_event_id_groups,
  profile.rows_with_missing_county_code,
  profile.rows_with_missing_begin_time
FROM profile CROSS JOIN event_checks;

-- Q2: PROSPECTIVE stronger diagnostics. NOT EXECUTED; no observed counts claimed.
-- Check all annual-table rows belonging to eligible IDs, including rows outside
-- the target filter. This addresses the limitation of P0's target-only checks.
-- Assignment conflicts require investigation before publishing a capture; do
-- not resolve them with ANY_VALUE or arbitrary row selection. County formatting
-- is only a syntax check, not validation against an authoritative county list.
-- Multiple county labels are diagnostic; a canonical dimension mapping must
-- resolve them consistently. Missing/repeated location indexes do not by
-- themselves invalidate an event-level fact and are not assumed to equal zero.
-- Source begin values are civil DATETIME values, not proven UTC timestamps.
-- Missing scope fields anywhere in the captured annual source require review:
-- their eligibility cannot be established by silently filtering them out.
WITH normalized AS (
  SELECT
    NULLIF(TRIM(CAST(event_id AS STRING)), '') AS event_id,
    SAFE_CAST(state_fips_code AS INT64) AS state_fips,
    NULLIF(UPPER(TRIM(cz_type)), '') AS county_or_zone,
    NULLIF(TRIM(CAST(cz_fips_code AS STRING)), '') AS county_code,
    NULLIF(TRIM(cz_name), '') AS county_name,
    NULLIF(LOWER(TRIM(event_type)), '') AS hazard,
    event_begin_time,
    NULLIF(TRIM(CAST(location_index AS STRING)), '') AS location_index
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_2024`
), scoped AS (
  SELECT *,
    state_fips = 27 AND county_or_zone = 'C'
      AND hazard IN ('hail', 'thunderstorm wind', 'tornado', 'flash flood') AS is_target
  FROM normalized
), target AS (
  SELECT * FROM scoped WHERE is_target
), eligible_ids AS (
  SELECT DISTINCT event_id FROM target WHERE event_id IS NOT NULL
), related_annual_rows AS (
  SELECT scoped.*
  FROM scoped INNER JOIN eligible_ids USING (event_id)
), annual_event_groups AS (
  SELECT
    event_id,
    COUNT(*) AS annual_rows,
    COUNTIF(NOT COALESCE(is_target, FALSE)) AS out_of_scope_rows,
    COUNT(DISTINCT TO_JSON_STRING(STRUCT(
      state_fips, county_or_zone, county_code, hazard, event_begin_time
    ))) AS annual_assignment_versions
  FROM related_annual_rows
  GROUP BY event_id
), annual_checks AS (
  SELECT
    COUNT(*) AS eligible_event_ids_checked,
    COALESCE(SUM(annual_rows), 0) AS annual_rows_for_eligible_ids,
    COUNTIF(out_of_scope_rows > 0) AS eligible_ids_with_out_of_scope_rows,
    COUNTIF(annual_assignment_versions > 1)
      AS eligible_ids_with_conflicting_annual_assignments
  FROM annual_event_groups
), annual_scope_checks AS (
  SELECT COUNTIF(state_fips IS NULL OR county_or_zone IS NULL OR hazard IS NULL)
    AS annual_rows_missing_scope_fields
  FROM scoped
), target_checks AS (
  SELECT
    COUNTIF(county_code IS NULL
      OR NOT REGEXP_CONTAINS(county_code, r'^[0-9]{1,3}$')
      OR SAFE_CAST(county_code AS INT64) NOT BETWEEN 1 AND 999)
      AS target_invalid_county_code_format_rows,
    COUNTIF(county_name IS NULL) AS target_missing_county_name_rows,
    COUNTIF(event_begin_time IS NULL OR EXTRACT(YEAR FROM event_begin_time) != 2024)
      AS target_missing_or_non2024_begin_rows,
    COUNTIF(location_index IS NULL) AS target_rows_missing_location_index
  FROM target
), county_groups AS (
  SELECT
    SAFE_CAST(county_code AS INT64) AS county_code_number,
    COUNT(DISTINCT county_name) AS county_label_count
  FROM target
  WHERE REGEXP_CONTAINS(county_code, r'^[0-9]{1,3}$')
    AND SAFE_CAST(county_code AS INT64) BETWEEN 1 AND 999
  GROUP BY county_code_number
), county_checks AS (
  SELECT COUNTIF(county_label_count > 1) AS target_county_codes_with_multiple_labels
  FROM county_groups
), location_groups AS (
  SELECT event_id, location_index, COUNT(*) AS rows_per_event_location
  FROM target
  WHERE event_id IS NOT NULL AND location_index IS NOT NULL
  GROUP BY event_id, location_index
), location_checks AS (
  SELECT COUNTIF(rows_per_event_location > 1) AS repeated_target_event_location_groups
  FROM location_groups
)
SELECT annual_checks.*, annual_scope_checks.*, target_checks.*,
  county_checks.*, location_checks.*
FROM annual_checks
CROSS JOIN annual_scope_checks
CROSS JOIN target_checks
CROSS JOIN county_checks
CROSS JOIN location_checks;
