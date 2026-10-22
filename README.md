# WeatherForge Warehouse

**David Braun · SEIS 732 · P0 proposal · Instructor approval pending review**

This P0 proposes historical reported-event counts for Minnesota county emergency-management staff discussing preparedness. The audience is a classroom scenario; no stakeholder interviews or validated client requirements are claimed.

The scope is **2024**, Minnesota state FIPS **27**, county-coded records (`cz_type = 'C'`), and **hail, thunderstorm wind, tornado, and flash flood**:

1. Which Minnesota counties have the most distinct reported events for each selected hazard in 2024?
2. How are those events distributed across the months of 2024?

One year describes observed frequency and monthly distribution. It does not establish recurring seasonality, forecasts, or exposure-adjusted risk. P0 covers the proposal and source checks; warehouse implementation and final event-grain/key decisions follow in P1.

## Files and verified source

| File | Purpose |
| --- | --- |
| [README.md](README.md) | Scope, review item, and submission handoff |
| [.gitignore](.gitignore) | Exclude source extracts and local credentials/artifacts |
| [docs/p0-feasibility.md](docs/p0-feasibility.md) | Nine-section proposal and need-to-source fit |
| [sql/00_feasibility.sql](sql/00_feasibility.sql) | Sequential, read-only Q1–Q3 checks |
| [evidence/p0-feasibility-results.md](evidence/p0-feasibility-results.md) | Actual metadata, query outputs, costs, and interpretation |

NOAA/NCEI Storm Events is distributed through BigQuery public data. **Codex completed Q1–Q3** through the existing course access in execution project `seis-732-david`, with dataset and query location **US**:

- **Q1:** Verified `bigquery-public-data.noaa_historic_severe_storms.storms_2024` among 77 annual tables spanning 1950–2026.
- **Q2:** Confirmed all nine requested fields and expected types.
- **Q3:** Found 885 target rows and 809 distinct event IDs across 80 county codes, all four hazards, and April–September. The 39 repeated target IDs have no conflicts in the checked county/hazard/start-time attributes within that subset. The results support both questions, subject to the P1 grain decision and reporting limitations.

Q3 processed **5.06 MB** and billed **10 MB**, within the **1 GiB** per-query limit. See the evidence file for metadata, exact outputs, and interpretation. Source rows and distinct event counts remain separate measures.

## Review and submission

**David's personal review:** Confirm that the rationale and proposed emergency-management audience in proposal section 2 reflect your evaluation; revise them if needed. The accountability note identifies tool assistance without claiming completed human review.

After your personal review, submit the fixed pushed commit URL in Canvas. The final handoff provides the populated block and the submitted commit's anonymous access check. This reusable template omits its own commit SHA; obtain it with `git rev-parse HEAD` in the reviewed checkout or copy the commit URL from GitHub.

```text
P0 commit: https://github.com/DavidBraun777/WeatherForge-Warehouse/commit/[FULL_COMMIT_SHA]
Proposal: docs/p0-feasibility.md
Source/provider: NOAA/NCEI Storm Events Database, through BigQuery public data
Dataset: bigquery-public-data.noaa_historic_severe_storms
Verified table: bigquery-public-data.noaa_historic_severe_storms.storms_2024
Instructor access: Public repository; exact commit access result in the publication handoff
Question for review: None; event-grain/key design is the first P1 decision
```

## Prior work and attribution

This separate SEIS 732 repository builds on experience with NOAA ingestion, cleaning, normalization, and analytics preparation from [WeatherForge](https://github.com/DavidBraun777/WeatherForge). That collaborative SEIS 745 project credits **David Braun, Odin Lee, and Jannah ElNemr** in the [case study](https://www.dbraun.io/case-studies/weatherforge). This P0 adds new BigQuery profiling and evidence; it imports no earlier graded deliverables, data files, or Git history. A future StormIQ application is outside this P0.

Credit [NOAA/NCEI](https://www.ncei.noaa.gov/access/storm-events-database/) for the source data and Google for its BigQuery distribution. Store only metadata and aggregate evidence here. AI/tool assistance and performed checks are disclosed in [proposal section 9](docs/p0-feasibility.md#9-aitool-accountability).
