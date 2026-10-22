# P0 feasibility results

**Q1–Q3 completed by Codex on October 21, 2026, America/Chicago (CDT, UTC−05:00).** These are live BigQuery metadata and aggregate findings, not source-record extracts. David's personal review remains outstanding; instructor P0 approval is pending review.

## 1. Source and access

| Item | Verified record |
| --- | --- |
| Source dataset | `bigquery-public-data.noaa_historic_severe_storms` |
| Selected annual table (Q1) | `bigquery-public-data.noaa_historic_severe_storms.storms_2024` |
| Course execution project | `seis-732-david`, confirmed in BigQuery Studio's active project and query job IDs |
| Execution date and operator | October 21, 2026, 21:42–21:45 CDT (America/Chicago, UTC−05:00); **Codex**, using David's existing authenticated Chrome session |
| Dataset / query location | `US`, inspected in Dataset Details and confirmed in all query jobs; explicitly selected for capped Q1, Q2, and Q3 |
| Course-environment access | Q1, Q2, and Q3 succeeded. No local `bq`/`gcloud` installation or BigQuery connector was available; execution used BigQuery Studio. |
| Visible additional use restrictions | None observed in inspected dataset/table Details. Dataset labels identify the source and confidentiality as public; table Description is blank. NOAA attribution and reporting limitations still apply. |
| Table type / row metadata | `BASE TABLE`; Table Details reports 85,896 rows, matching Q3 |
| Table created | April 18, 2024, 22:13:15 CDT (UTC−05:00) |
| Table last modified | October 20, 2026, 23:09:21 CDT (UTC−05:00) |
| Table storage | Total/active logical size 16.51 MB; current physical size 2.59 MB; total physical size 20.75 MB, including 18.15 MB time travel (UI display units/rounding) |
| Table expiration / declared primary key | Expiration `NEVER`; no primary key displayed |

The target subset is Minnesota state FIPS 27, county-coded records (`cz_type = 'C'`), and hail, thunderstorm wind, tornado, and flash flood. No scope change was required. [NCEI metadata](https://www.ncei.noaa.gov/metadata/geoportal/rest/metadata/item/gov.noaa.ncdc:C00510/html) requests dataset citation and notes report-accuracy limitations. The BigQuery refresh schedule has not been established; modification time does not establish reporting completeness.

The Dataset Details page also reported insufficient permission for its optional `SCHEMATA_REPLICAS` display. This did not prevent reading the dataset location, table metadata, or executing Q1–Q3; no permission changes were made.

## 2. Query record

The [SQL file](../sql/00_feasibility.sql) contains three read-only statements. Codex inspected each validator estimate before execution, selected the table after Q1, and checked Q2 before Q3. No assignment/syllabus document or course-specific cost ceiling was supplied in the workspace or request attachment, so the requested **1 GiB (1,073,741,824 bytes) per-query ceiling** was used. The explicit Maximum bytes billed setting and `US` location were saved before the recorded capped Q1 run and retained for Q2/Q3. Temporary query results were used; no permanent tables were written.

| Query | Creation time, October 21 CDT | Validator estimate | Processed / billed | Explicit bytes cap |
| --- | --- | --- | --- | --- |
| Q1 initial inventory | 21:42:34 | 10 MB | 10 MB / 10 MB | Not yet configured; see execution note below |
| Q1 capped inventory | 21:43:33 | 10 MB | 10 MB / 10 MB | 1,073,741,824 |
| Q2 selected schema | 21:44:33 | 10 MB | 10 MB / 10 MB | 1,073,741,824 |
| Q3 aggregate profile | 21:45:19 | 5.06 MB | 5.06 MB / 10 MB | 1,073,741,824 |

Values preserve BigQuery Studio's displayed `MB` units and rounding; exact integer processed/billed byte totals were not exposed in the inspected UI. All four jobs were below 1 GiB. Q3 completed at 21:45:20 CDT. A Minnesota filter or `LIMIT` was not treated as a scan-size guarantee.

**Execution note:** The initial Q1 inventory completed before the explicit maximum-bytes setting was saved. Its inspected estimate and actual bill were both 10 MB. Codex repeated Q1 once after saving the cap; the capped run is the inventory used below. This extra run is disclosed rather than claiming every run had the configured cap.

Job references (all in `seis-732-david`, location `US`; opening these requires course-project job access):

- Initial Q1: `job_gy2xF1TvFuo4aHK_iV6WzJDI3bXY`
- Capped Q1: `job_PZjAsX1H2ctO5ZSsZ74cXLKcqcaT`
- Q2: `job_znZyWUmVxiKDan8BLWrrve5dtN_H`
- Q3: `job_LwSPvhnA3uM4nswg8PpO_ZlbG_vH`

### Q1 annual inventory and selection

The query returned **77 objects**, all `BASE TABLE`, comprising every annual name from `storms_1950` through `storms_2026` inclusive. Codex inspected the metadata-only JSON export and checked that this range had no gaps. The selected row is:

| table_name | table_type |
| --- | --- |
| `storms_2024` | `BASE TABLE` |

The existing 2024 candidate is available and Q2/Q3 establish its usability. It is retained as the single historical year; the existence of 2025/2026 tables does not expand P0.

### Q2 schema

All nine requested fields were returned in ordinal order. The original Q3 expressions matched the live schema and required no logic correction.

| column_name | data_type | is_nullable |
| --- | --- | --- |
| `event_id` | STRING | YES |
| `state_fips_code` | STRING | YES |
| `event_type` | STRING | YES |
| `cz_type` | STRING | YES |
| `cz_fips_code` | STRING | YES |
| `cz_name` | STRING | YES |
| `event_begin_time` | DATETIME | YES |
| `event_end_time` | DATETIME | YES |
| `location_index` | STRING | YES |

### Q3 aggregate profile

The query returned one row, transcribed from BigQuery's aggregate JSON result. Integer values retain the JSON display's string representation. Begin/end values are source civil DATETIME values; they are not asserted to be UTC timestamps.

```json
{
  "source_rows": "85896",
  "source_distinct_event_ids": "69801",
  "source_missing_event_id_rows": "0",
  "source_earliest_begin": "2024-01-01T00:00:00",
  "source_latest_begin": "2024-12-31T23:30:00",
  "source_rows_missing_scope_fields": "0",
  "target_rows": "885",
  "target_distinct_event_ids": "809",
  "target_missing_event_id_rows": "0",
  "target_earliest_begin": "2024-04-16T13:50:00",
  "target_latest_begin": "2024-09-21T14:53:00",
  "target_latest_end": "2024-09-21T14:53:00",
  "target_missing_begin_rows": "0",
  "target_missing_end_rows": "0",
  "target_end_before_begin_rows": "0",
  "target_missing_county_code_rows": "0",
  "target_missing_county_name_rows": "0",
  "target_distinct_county_codes": "80",
  "target_distinct_hazards": "4",
  "target_distinct_months": "6",
  "target_repeated_event_ids": "39",
  "target_conflicting_event_ids": "0"
}
```

## 3. Interpretation and decision

**Retain 2024 and both questions.** The target contains 885 source rows representing 809 distinct nonmissing event IDs, 80 source county codes, and all four selected hazards. Target IDs, county code/name, and begin/end times have no missing values under Q3's checks, and no target end precedes its begin. These findings support later distinct reported-event counts by county/hazard and by month; P0 does not yet produce the county rankings or monthly summaries.

Target begin times span April 16–September 21, 2024, with records in six months. The full source's observed begin times span January 1–December 31. This supports describing the recorded monthly distribution for 2024; six target months do not establish recurring seasonality, prove missing reporting in the other months, or imply exposure-adjusted risk. County codes have not been independently matched to county boundaries, and observed date ranges do not prove complete reporting.

**P1 grain/key decision remains open.** Thirty-nine target event IDs appear on multiple source rows, accounting for the difference between 885 rows and 809 IDs. Google's [importer](https://github.com/GoogleCloudPlatform/public-datasets-pipelines/blob/main/datasets/noaa/pipelines/_images/run_csv_transform_kub/csv_transform.py) joins event details to multiple locations, so repetition can be legitimate. Zero target IDs have conflicting county-code/hazard/begin-time combinations in this check. This does not test global ID consistency outside the target, county-name agreement, or uniqueness of an event-location key. No rows were deleted and no final deduplication rule was selected. P1 must establish the event fact grain and key, date semantics, and treatment of location rows and exceptions.

## 4. Repository access and review status

- **Repository:** [WeatherForge-Warehouse](https://github.com/DavidBraun777/WeatherForge-Warehouse), verified public through GitHub repository metadata on October 21, 2026.
- **Instructor access:** The repository is public; no `37chandler` invitation is required. The exact submitted commit URL and its unauthenticated access result are recorded in the publication handoff, avoiding a self-referential SHA in this file.
- **David's personal review:** Confirm the proposed classroom audience and rationale in [proposal section 2](../docs/p0-feasibility.md#2-audience-and-need). No completed personal review is claimed.
- **Instructor P0 decision:** **Pending review.** Approval follows submission; no acceptance is promised.
- **Measurement blockers:** None for Q1–Q3. The event-grain decision is intentionally deferred to P1.
