# P0 — Need, Audience, Dataset & Feasibility

**Proposal for instructor review.** This revision incorporates David's choice of insurance analysts as the primary audience and his goal of extending WeatherForge. Codex completed Q1–Q3 on October 21, 2026; results are recorded in [the evidence file](../evidence/p0-feasibility-results.md). Instructor P0 approval is **pending review**.

## 1. Working title

**WeatherForge Warehouse: Minnesota Storm History for Insurance Analysts**

## 2. Audience and need

The primary audience is **an insurance analyst responsible for catastrophe preparedness in Minnesota**. The proposed recurring task is to select historical county–hazard–month cases for deeper review and preparedness exercises. A consistent summary would help the analyst identify cases to investigate without manually scanning the full event table. This is a classroom use-case hypothesis; no insurer interviews or demonstrated business benefit are claimed.

The analyst could filter a county or hazard, compare reported-event counts, and shortlist historical periods for follow-up. A later study could compare those cases with insurer-held claims and exposure data. The present source does not establish which counties have the highest insured risk or expected claim workload.

**David's rationale:** David selected insurance analysts because he wants to pursue demanding quantitative work and build WeatherForge into a useful continuing product. His longer-term interests include both weather-related alerts and forecasting insurance claims. He is willing to begin with a bounded historical analysis if it provides a useful foundation, and asks the instructor to assess this semester scope.

The earlier collaborative [WeatherForge project](https://github.com/DavidBraun777/WeatherForge) is credited to David Braun, Odin Lee, and Jannah ElNemr in its [case study](https://www.dbraun.io/case-studies/weatherforge). This separate course repository adds new BigQuery profiling, evidence, and later warehouse modeling. Earlier graded deliverables, source-data files, and Git history are not imported.

## 3. Proposed analytical product and questions

The proposed semester product is a small historical dashboard backed by BigQuery serving views, with county/hazard filters, distinct reported-event counts, and monthly summaries. It would support the analyst's retrospective case selection. P0 supplies the proposal and feasibility evidence; implementation follows in later milestones.

The bounded scope is **2024**, Minnesota state FIPS **27**, county-coded records (`cz_type = 'C'`), and four hazards: **hail, thunderstorm wind, tornado, and flash flood**.

1. Which Minnesota counties have the most distinct reported events for each selected hazard in 2024?
2. How are those events distributed across the months of 2024?

**Deliverable boundary:** These questions describe recorded events in 2024. Live alerts and claims forecasts remain longer-term WeatherForge goals. This semester proposal does not promise them: the verified source has no claims outcome, insured-exposure, or live-weather feed supporting those capabilities. One year also does not establish recurring seasonality, forecast skill, or exposure-adjusted risk. Correlation findings are not a required outcome; the event counting and analysis units must be established before any exploratory relationship analysis.

**Instructor decision requested:** Is this historical dashboard for insurance preparedness a useful and manageable semester scope, with event-grain validation in P1 and live alerts/claims forecasting reserved for later work?

## 4. Source identification and access

- **Provider:** NOAA/NCEI Storm Events Database, distributed through Google BigQuery public data.
- **Project/dataset:** `bigquery-public-data.noaa_historic_severe_storms`.
- **Verified table:** `bigquery-public-data.noaa_historic_severe_storms.storms_2024`. Q1 confirmed it among 77 annual base tables (1950–2026); 2024 is retained as the one historical year. Codex ran Q1–Q3 in execution project `seis-732-david`, location `US`, on October 21, 2026 (America/Chicago).
- **Approval route:** BigQuery public-dataset proposal; instructor P0 approval pending review.
- **Use and attribution:** Credit NOAA/NCEI and the BigQuery distribution. [NCEI's dataset metadata](https://www.ncei.noaa.gov/metadata/geoportal/rest/metadata/item/gov.noaa.ncdc:C00510/html) asks users to cite the dataset and notes that some reports may be unverified. No additional restrictions were observed in the inspected dataset/table details on October 21; that observation is recorded in the evidence file. Keep source rows and extracts out of the repository.
- **Source links:** [NOAA Storm Events](https://www.ncei.noaa.gov/access/storm-events-database/) and [BigQuery public datasets](https://docs.cloud.google.com/bigquery/public-data).

## 5. Quick source profile

Google's published [schema](https://github.com/GoogleCloudPlatform/public-datasets-pipelines/blob/main/datasets/noaa/pipelines/noaa/data/noaa_historic_severe_storms_schema.json) and [importer](https://github.com/GoogleCloudPlatform/public-datasets-pipelines/blob/main/datasets/noaa/pipelines/_images/run_csv_transform_kub/csv_transform.py) indicate that event details can be joined to multiple locations. A source row may therefore be an event-location record; repeated `event_id` values are not automatically erroneous duplicates.

The needed fields are `event_id`, `state_fips_code`, `cz_type`, `cz_fips_code`, `cz_name`, `event_type`, and `event_begin_time`. End time and location index provide additional quality/grain context. [Q1–Q3](../sql/00_feasibility.sql) confirmed the needed STRING/DATETIME types and profiled **85,896 source rows / 69,801 distinct event IDs**. The target has **885 rows / 809 distinct event IDs**, 80 county codes, all four hazards, and six observed months (April–September 2024). No target IDs, county code/name, or begin/end times were missing under the checks; 39 target IDs repeat, with zero conflicts in the tested county-code/hazard/begin-time combination. Full output and billing are in [the evidence file](../evidence/p0-feasibility-results.md).

These counts describe the October 21, 2026 execution; they are not a new query run on the documentation-review date. Published documentation is background evidence; the recorded BigQuery outputs establish what was present in the selected object at execution. NOAA's [bulk-format documentation](https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/Storm-Data-Bulk-csv-Format.pdf) defines `event_id` as an event within an episode and `location_index` as a location within that event. Distinct event IDs therefore count reported events, not independent storm systems. NOAA's [metadata](https://www.ncei.noaa.gov/metadata/geoportal/rest/metadata/item/gov.noaa.ncdc:C00510/html) describes monthly upstream updates with possible reporting delays; the BigQuery refresh schedule remains unverified. Observed minimum/maximum dates do not prove complete reporting.

## 6. Need-to-source fit

| Proposed question | Needed fields or concepts | Verified source object | Why the source supports feasibility | Gap or assumption to test in P1 |
| --- | --- | --- | --- | --- |
| Which counties have the most distinct reported events for each selected hazard in 2024? | Event ID, county code/name, hazard | `storms_2024` in the dataset above | Q2 confirms fields; Q3 finds 809 target IDs, 80 county codes, all four hazards, and no missing target ID/county fields. These fields can support a historical case shortlist. | Establish the event fact grain/key, handle repeated locations, and validate county codes. Counts do not rank insured risk. |
| How are those events distributed across the months of 2024? | Event ID, begin date, hazard | Same `storms_2024` table | Q2 confirms DATETIME begin times; Q3 finds no missing target begin times and six recorded months within 2024. These fields can identify historical periods for review. | Choose consistent date semantics and define the calendar display, including zero recorded counts. Absence of reports does not establish complete observation or predict future timing. |

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

- **Tools and consequential assistance:** ChatGPT/Codex assisted with source comparison, proposal and SQL drafting, aggregate-result interpretation, source-documentation checks, and repository files/commits. Codex executed Q1–Q3 in `seis-732-david` (`US`) on October 21. The evidence records outputs, job references, costs, and the initial Q1 run before the explicit cap was saved.
- **Verification performed through tools:** The recorded BigQuery runs verified access, live field types, counts, date coverage, missing values, and the stated target-only ID checks. ChatGPT checked NOAA documentation, Google's importer, and consistency between the SQL and written evidence. Documentation is not substituted for executed query results.
- **David's review and decisions:** David reports reviewing the preceding proposal, SQL, and recorded results. He selected insurance analysts as the primary audience and identified alerts and claims forecasting as longer-term goals. This revision replaces the earlier AI-proposed county-emergency-management scenario, retains the verified source and two historical questions, and asks the instructor to evaluate the bounded insurance use case.
- **Remaining learning and modeling issue:** David identified the distinction between source rows and distinct events as unclear. Section 8 explains it and makes grain/key validation the first P1 decision; this note does not claim independent mastery of that issue. The recorded query operator remains Codex.
- **Revision status:** The October 27 documentation revision uses the existing October 21 evidence. It adds no query execution or SQL changes. David remains responsible for the submitted claims and an independent explanation; instructor approval remains pending.
