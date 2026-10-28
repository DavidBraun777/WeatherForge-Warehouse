# P0 — Need, Audience, Dataset & Feasibility

**Proposal for instructor review.** Codex completed Q1–Q3 on October 21, 2026; live results are recorded in [the evidence file](../evidence/p0-feasibility-results.md). David's personal review remains outstanding. Instructor P0 approval is **pending review**; approval follows submission.

## 1. Working title

**WeatherForge Warehouse: Minnesota Storm Event Profile**

## 2. Audience and need

The proposed audience is a Minnesota county emergency-management coordinator preparing the county's annual tabletop-exercise agenda. The recurring decision is which historical hazard scenarios to bring forward for discussion. The coordinator needs a consistent way to compare the county's reported events with those in other Minnesota counties and review when those events occurred during 2024.

A dashboard could make those county, hazard, and month comparisons available together. The coordinator could use the summaries to shortlist a hazard scenario and a historical period to investigate, then check that choice against local knowledge and existing preparedness plans. The summaries are historical discussion inputs; a single year does not justify a future exercise calendar, a forecast, or a resource-allocation ranking. This is a proposed classroom scenario; no stakeholder interviews, client engagement, or requirements validation are claimed.

**Rationale prepared from David's supplied background:** The earlier collaborative [WeatherForge project](https://github.com/DavidBraun777/WeatherForge), credited to David Braun, Odin Lee, and Jannah ElNemr in its [case study](https://www.dbraun.io/case-studies/weatherforge), worked with raw NOAA weather data, including GHCN `.dly` ingestion and Storm Events. David's experience with cleaning and normalization, Bronze/Silver/Gold organization, data quality, lineage, and preparing data for analytics and BI provides a foundation for this new warehousing work. Continuing the domain lets this course project add BigQuery source profiling and evidence, followed later by warehouse modeling and validation. The Minnesota classroom scenario provides a focused use for county and monthly event summaries.

This coursework remains in the separate WeatherForge-Warehouse repository. Earlier graded deliverables, data files, and Git history are not imported. A future StormIQ business application and later portfolio integration are outside P0.

**David's personal review item:** Confirm that this proposed audience and rationale reflect the use case and reasoning you want to present. That review has not yet been completed.

## 3. Proposed analytical product and questions

The proposed later analytical product is a small dashboard using BigQuery serving views to compare distinct reported events by county, hazard, and month in **2024**. P0 prepares the proposal and verifies source feasibility; it does not implement a warehouse, dashboard, ingestion pipeline, or deployment. The scope is Minnesota state FIPS 27, county-coded records (`cz_type = 'C'`), and four hazards: hail, thunderstorm wind, tornado, and flash flood.

1. Which Minnesota counties have the most distinct reported events for each selected hazard in 2024?
2. How are those events distributed across the months of 2024?

This describes historical reported-event frequency within the observed year. A single year does not establish recurring seasonality, forecasts, or exposure-adjusted risk. Damage analysis and multiple-year expansion are outside P0.

## 4. Source identification and access

- **Provider:** NOAA/NCEI Storm Events Database, distributed through Google BigQuery public data.
- **Project/dataset:** `bigquery-public-data.noaa_historic_severe_storms`.
- **Verified table:** `bigquery-public-data.noaa_historic_severe_storms.storms_2024`. Q1 confirmed it among 77 annual base tables (1950–2026); 2024 is retained as the one historical year. Codex ran Q1–Q3 in execution project `seis-732-david`, location `US`, on October 21, 2026 (America/Chicago).
- **Approval route:** BigQuery public-dataset proposal; instructor P0 approval pending review.
- **Use and attribution:** Credit NOAA/NCEI and the BigQuery distribution. [NCEI's dataset metadata](https://www.ncei.noaa.gov/metadata/geoportal/rest/metadata/item/gov.noaa.ncdc:C00510/html) asks users to cite the dataset and notes that some reports may be unverified. Record any additional visible listing/table restrictions in the evidence file. Keep source rows and extracts out of the repository.
- **Source links:** [NOAA Storm Events](https://www.ncei.noaa.gov/access/storm-events-database/) and [BigQuery public datasets](https://docs.cloud.google.com/bigquery/public-data).

## 5. Quick source profile

Google's published [schema](https://github.com/GoogleCloudPlatform/public-datasets-pipelines/blob/main/datasets/noaa/pipelines/noaa/data/noaa_historic_severe_storms_schema.json) and [importer](https://github.com/GoogleCloudPlatform/public-datasets-pipelines/blob/main/datasets/noaa/pipelines/_images/run_csv_transform_kub/csv_transform.py) indicate that event details can be joined to multiple locations. A source row may therefore be an event-location record; repeated `event_id` values are not automatically erroneous duplicates.

The needed fields are `event_id`, `state_fips_code`, `cz_type`, `cz_fips_code`, `cz_name`, `event_type`, and `event_begin_time`. End time and location index provide additional quality/grain context. [Q1–Q3](../sql/00_feasibility.sql) confirmed the needed STRING/DATETIME types and profiled **85,896 source rows / 69,801 distinct event IDs**. The target has **885 rows / 809 distinct event IDs**, 80 county codes, all four hazards, and six observed months (April–September 2024). No target IDs, county code/name, or begin/end times were missing under the checks; 39 target IDs repeat, with zero conflicts in the tested county-code/hazard/begin-time combination. Full output and billing are in [the evidence file](../evidence/p0-feasibility-results.md).

These counts describe the October 21, 2026 execution; they are not a new query run on the documentation-review date. Published documentation is background evidence; the recorded BigQuery outputs establish what was present in the selected object at execution. NOAA's [bulk-format documentation](https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/Storm-Data-Bulk-csv-Format.pdf) defines `event_id` as an event within an episode and `location_index` as a location within that event. Distinct event IDs therefore count reported events, not independent storm systems. NOAA's [metadata](https://www.ncei.noaa.gov/metadata/geoportal/rest/metadata/item/gov.noaa.ncdc:C00510/html) describes monthly upstream updates with possible reporting delays; the BigQuery refresh schedule remains unverified. Observed minimum/maximum dates do not prove complete reporting.

## 6. Need-to-source fit

| Proposed question | Needed fields or concepts | Verified source object | Why the source supports feasibility | Gap or assumption to test in P1 |
| --- | --- | --- | --- | --- |
| County/hazard event counts | Event ID, county code/name, hazard | `storms_2024` in the dataset above | Q2 confirms fields; Q3 finds 809 target IDs, 80 county codes, all four hazards, and no missing target ID/county fields. | Establish the event fact grain/key, handle repeated locations, and validate county codes. |
| Monthly event distribution | Event ID, begin date, hazard | Same `storms_2024` table | Q2 confirms DATETIME begin times; Q3 finds no missing target begin times and six recorded months within 2024. | Choose consistent date semantics and distinguish no recorded events from incomplete coverage. |

## 7. Feasibility risks and response

1. **Repeated event records.** Published import code joins locations to events. Q3 keeps source-row counts separate from distinct event counts and measures repeated IDs and conflicting county/hazard/start-time combinations within the target subset. Repeats may represent multiple locations; they are not automatically deleted. The target-only check cannot establish global event-ID consistency across out-of-scope records. P1 will establish the event fact and handle exceptions before serving counts.
2. **Limited historical evidence.** One observed year and reported events cannot establish typical seasonality or underlying risk. Label the period and report counts with these limits.
3. **Source changes and query cost.** Q1–Q3 succeeded in the course environment on October 21, 2026; Q3 processed **5.06 MB** and billed **10 MB**. The selected table had been modified on October 20, so an annual table is not assumed to be immutable. Before a rerun or scope expansion, recheck inventory/schema, match the query location to the dataset, and inspect estimates or dry runs. Follow any documented course cost limit; otherwise retain the **1 GiB (1,073,741,824 bytes) billed per-query ceiling** used for the recorded capped runs. Stop if the estimate exceeds the ceiling. A Minnesota filter or `LIMIT` does not guarantee a smaller scan.

**Fallback:** Select another verified historical annual table from the same dataset while retaining the Minnesota county scope and four hazards. If the source checks cannot be completed within available access and the cost limit, preserve the proposal as a draft and identify the missing evidence.

## 8. First P1 decision

Establish the exact event fact grain and key: whether each nonmissing `event_id` consistently identifies one county, hazard, and start time, and how repeated locations and conflicting records should be handled.

## 9. AI/tool accountability

ChatGPT helped compare sources and draft the starter proposal and feasibility SQL. Codex revised the package using David's supplied background, retained the one-year Minnesota/four-hazard scope and two questions, and clarified the P0 boundary and event-grain limitations. Codex checked Git state, source attribution, SQL, and package consistency, and executed Q1–Q3 through the existing BigQuery Studio session in `seis-732-david` (`US`). The live schema required no SQL logic change; 2024 was retained after profiling. The evidence records actual results, costs, and the extra initial Q1 run before the explicit cap was saved. David's personal review is still required; no completed human review or reflection is claimed.

On October 27, 2026 (America/Chicago), ChatGPT reviewed the repository against the supplied P0 instructions, made the audience's recurring decision explicit, updated the source-change/cost response, and checked NOAA documentation and Google's importer. This review used the existing October 21 aggregate evidence and did not rerun BigQuery or change the SQL. David remains responsible for reviewing and defending the proposal; instructor approval remains pending.
