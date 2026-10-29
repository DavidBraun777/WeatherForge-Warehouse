# P0 — Need, Audience, Dataset & Feasibility

**Proposal for instructor review.** Q1–Q3 were completed on October 21, 2026; table selection and source measurements are recorded in [the evidence file](../evidence/p0-feasibility-results.md). Instructor P0 approval is **pending review**.

## 1. Working title

**WeatherForge Warehouse: Minnesota Storm History for Insurance Analysts**

## 2. Audience and need

The primary audience is **an insurance analyst responsible for catastrophe preparedness in Minnesota**. The proposed recurring task is to select historical county–hazard–month cases for deeper review and preparedness exercises. A consistent summary would help the analyst identify cases to investigate without manually scanning the full event table. This is a classroom use-case hypothesis; no insurer interviews or demonstrated business benefit are claimed.

The analyst could filter a county or hazard, compare reported-event counts, and shortlist historical periods for follow-up. A later study could compare those cases with insurer-held claims and exposure data. The present source does not establish which counties have the highest insured risk or expected claim workload.

**David's rationale:** David selected insurance analysts because he wants to pursue demanding quantitative work and build WeatherForge into a useful continuing product. His longer-term interests include both weather-related alerts and forecasting insurance claims. He is willing to begin with a bounded historical analysis if it provides a useful foundation, and asks the instructor to assess this semester scope.

The earlier collaborative [WeatherForge project](https://github.com/DavidBraun777/WeatherForge) is credited to David Braun, Odin Lee, and Jannah ElNemr in its [case study](https://www.dbraun.io/case-studies/weatherforge). This separate course repository adds new BigQuery profiling, evidence, and later warehouse modeling. Earlier graded deliverables, source-data files, and Git history are not imported.

## 3. Proposed analytical product and questions

The proposed later analytical product is a small dashboard using BigQuery serving views to compare distinct reported events by county, hazard, and month in **2024**. P0 prepares the proposal and verifies source feasibility; it does not implement a warehouse, dashboard, ingestion pipeline, or deployment.

The bounded scope is **2024**, Minnesota state FIPS **27**, county-coded records (`cz_type = 'C'`), and four hazards: **hail, thunderstorm wind, tornado, and flash flood**.

1. Which Minnesota counties have the most distinct reported events for each selected hazard in 2024?
2. How are those events distributed across the months of 2024?

**Deliverable boundary:** These questions describe recorded events in 2024. Live alerts and claims forecasts remain longer-term WeatherForge goals. This semester proposal does not promise them: the verified source has no claims outcome, insured-exposure, or live-weather feed supporting those capabilities. One year also does not establish recurring seasonality, forecast skill, or exposure-adjusted risk. Correlation findings are not a required outcome; the event counting and analysis units must be established before any exploratory relationship analysis.

**Instructor decision requested:** Is this historical dashboard for insurance preparedness a useful and manageable semester scope, with event-grain validation in P1 and live alerts/claims forecasting reserved for later work?

## 4. Source identification and access

- **Provider:** NOAA/NCEI Storm Events Database, distributed through Google BigQuery public data.
- **Project/dataset:** `bigquery-public-data.noaa_historic_severe_storms`.
- **Verified table:** `bigquery-public-data.noaa_historic_severe_storms.storms_2024`, confirmed by Q1 on October 21, 2026. Q1–Q3 ran in execution project `seis-732-david`, with dataset/query location `US`. The identifier, access, query date, and job references are recorded in the evidence file.
- **Approval route:** BigQuery public-dataset proposal; instructor P0 approval pending review.
- **Use and attribution:** Credit NOAA/NCEI and the BigQuery distribution. [NCEI's dataset metadata](https://www.ncei.noaa.gov/metadata/geoportal/rest/metadata/item/gov.noaa.ncdc:C00510/html) asks users to cite the dataset and notes that some reports may be unverified. No additional restrictions were observed in the inspected dataset/table details on October 21; that observation is recorded in the evidence file. Keep source rows and extracts out of the repository.
- **Source links:** [NOAA Storm Events](https://www.ncei.noaa.gov/access/storm-events-database/) and [BigQuery public datasets](https://docs.cloud.google.com/bigquery/public-data).

## 5. Quick source profile

Google's published [schema](https://github.com/GoogleCloudPlatform/public-datasets-pipelines/blob/main/datasets/noaa/pipelines/noaa/data/noaa_historic_severe_storms_schema.json) and [importer](https://github.com/GoogleCloudPlatform/public-datasets-pipelines/blob/main/datasets/noaa/pipelines/_images/run_csv_transform_kub/csv_transform.py) indicate that event details can be joined to multiple locations. A source row may therefore be an event-location record; repeated `event_id` values are not automatically erroneous duplicates.

The needed fields are `event_id`, `state_fips_code`, `cz_type`, `cz_fips_code`, `cz_name`, `event_type`, and `event_begin_time`. End time and location index provide additional quality/grain context. The recorded October 21, 2026 [Q1–Q3](../sql/00_feasibility.sql) execution confirmed all nine requested fields and their STRING/DATETIME types. Q3 recorded **885 target rows / 809 distinct event IDs**, 80 county codes, all four selected hazards, and six observed months (April–September 2024). Detailed quality checks and results are recorded in [the evidence file](../evidence/p0-feasibility-results.md).

These counts describe the October 21, 2026 execution; they are not a new query run on the documentation-review date. Published documentation is background evidence; the recorded BigQuery outputs establish what was present in the selected object at execution. NOAA's [bulk-format documentation](https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/Storm-Data-Bulk-csv-Format.pdf) defines `event_id` as an event within an episode and `location_index` as a location within that event. Distinct event IDs therefore count reported events, not independent storm systems. NOAA's [metadata](https://www.ncei.noaa.gov/metadata/geoportal/rest/metadata/item/gov.noaa.ncdc:C00510/html) describes monthly upstream updates with possible reporting delays; the BigQuery refresh schedule remains unverified. Observed minimum/maximum dates do not prove complete reporting.

## 6. Need-to-source fit

| Proposed question | Needed fields or concepts | Verified source object | Why the source supports feasibility | Gap or assumption to test in P1 |
| --- | --- | --- | --- | --- |
| County/hazard event counts | Event ID, county code/name, hazard | `storms_2024` in the dataset above | Q2 confirmed the fields; Q3 recorded 809 target IDs, 80 county codes, and all four hazards. | Establish one event fact and resolve repeated or conflicting event attributes. |
| Monthly event distribution | Event ID, begin date, hazard | Same `storms_2024` table | Q2 confirmed DATETIME begin times; Q3 recorded no missing target begin times and six observed months in 2024. | Choose consistent date semantics and distinguish no recorded events from incomplete coverage. |

## 7. Feasibility risks and response

1. **Repeated event records.** Published import code joins locations to events. Q3 keeps source-row counts separate from distinct event counts and measures repeated IDs and conflicting county/hazard/start-time combinations within the target subset. Repeats may represent multiple locations; they are not automatically deleted. The target-only check cannot establish global event-ID consistency across out-of-scope records. P1 will establish the event fact and handle exceptions before serving counts.
2. **Historical reporting and insurance interpretation.** The checks cover one year of reported events, with target records in six months. The current source does not establish claims, policy coverage, insured exposure, or real-time conditions. Label the product as a 2024 retrospective; use counts to select cases for investigation, not to estimate claim volume, set premiums, or rank insured risk. Keep alerts and claims forecasting outside the semester promise. The usefulness of the proposed insurance scenario remains subject to instructor review.
3. **Source changes and query cost.** Q1–Q3 succeeded in the course environment on October 21, 2026; Q3 processed **5.06 MB** and billed **10 MB**. The selected table had been modified on October 20, so an annual table is not assumed to be immutable. Before a rerun or scope expansion, recheck inventory/schema, match the query location to the dataset, and inspect estimates or dry runs. Follow any documented course cost limit; otherwise retain the **1 GiB (1,073,741,824 bytes) billed per-query ceiling** used for the recorded capped runs. Stop if the estimate exceeds the ceiling. A Minnesota filter or `LIMIT` does not guarantee a smaller scan.

**Fallback:** If county-code validation or implementation time makes county comparisons impractical, reduce the product to statewide monthly distinct reported-event counts for the same four hazards and 2024 table. Document the narrower use and seek instructor agreement for that material scope change.

## 8. First P1 decision

Establish the **event fact grain and key** before interpreting comparisons or correlations. Grain means what one fact-table row represents; a key identifies that row. The candidate is one reported event per validated `event_id` within the selected scope, with multiple locations handled at their own grain if needed.

The target contains **885 source rows but 809 distinct event IDs**. That is **76 rows beyond one row per ID**, spread across **39 repeated IDs**. These are not automatically 76 errors: multiple source rows can describe locations for the same event. Counting each source row as a new event could inflate the dashboard's measures.

P1 will check identifier and attribute consistency, decide how to retain location detail and handle exceptions, and then produce county/hazard/month summaries. The existing target-only conflict check supports feasibility but does not settle the final key or uniqueness of an event-location pair.

## 9. AI/tool accountability

ChatGPT helped compare sources and draft the starter materials and SQL. Codex revised the package using my supplied background, retained the one-year Minnesota scope with four hazards and two questions, and ran Q1–Q3 in the course BigQuery environment. Schema checks, results, and query costs are documented in the evidence file. I have reviewed the rationale, SQL, and recorded results.
