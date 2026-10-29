# WeatherForge Warehouse

**David Braun · SEIS 732 · P0 proposal · Instructor approval pending review**

This project proposes a historical storm-event dashboard for **an insurance analyst responsible for catastrophe preparedness in Minnesota**. County, hazard, and month comparisons would help shortlist historical cases for deeper review and preparedness exercises. This is a proposed classroom use case; insurer demand and business benefit have not been validated.

The scope is **2024**, Minnesota state FIPS **27**, county-coded records (`cz_type = 'C'`), and **hail, thunderstorm wind, tornado, and flash flood**:

1. Which Minnesota counties have the most distinct reported events for each selected hazard in 2024?
2. How are those events distributed across the months of 2024?

David's longer-term WeatherForge goals include weather-related alerts and forecasting insurance claims. The proposed semester contribution is a bounded historical dashboard and trustworthy warehouse foundation. Its source does not establish live conditions, claims, insured exposure, or forecast accuracy. P0 covers the proposal and source checks; implementation and the event-grain/key decision follow in later milestones.

## Files and verified source

| File | Purpose |
| --- | --- |
| [README.md](README.md) | Scope, review item, and submission handoff |
| [.gitignore](.gitignore) | Exclude source extracts and local credentials/artifacts |
| [docs/p0-feasibility.md](docs/p0-feasibility.md) | Nine-section proposal and need-to-source fit |
| [sql/00_feasibility.sql](sql/00_feasibility.sql) | Sequential, read-only Q1–Q3 checks |
| [evidence/p0-feasibility-results.md](evidence/p0-feasibility-results.md) | Actual metadata, query outputs, costs, and interpretation |

NOAA/NCEI Storm Events is distributed through BigQuery public data. **Codex completed Q1–Q3 on October 21, 2026** through the existing course access in execution project `seis-732-david`, with dataset and query location **US**. The October 27 documentation review retained these dated results and did not rerun BigQuery:

- **Q1:** Verified `bigquery-public-data.noaa_historic_severe_storms.storms_2024` among 77 annual tables spanning 1950–2026.
- **Q2:** Confirmed all nine requested fields and expected types.
- **Q3:** Found 885 target rows and 809 distinct event IDs across 80 county codes, all four hazards, and April–September. The 39 repeated target IDs have no conflicts in the checked county/hazard/start-time attributes within that subset. The results support both questions, subject to the P1 grain decision and reporting limitations.

Q3 processed **5.06 MB** and billed **10 MB**, within the **1 GiB** per-query limit. See the evidence file for metadata, exact outputs, and interpretation. Source rows and distinct event counts remain separate measures.

## Review and submission

**David's review and clarification:** David reports reviewing the proposal, SQL, and recorded results. He chose insurance analysts, wants both alerts and claims forecasting in the longer-term product, and asks the instructor to assess the usefulness and feasibility of this bounded semester scope. The row-versus-event distinction remains an identified learning and P1 modeling issue; proposal section 8 now explains it.

Submit the fixed pushed commit URL in Canvas after checking this revision. The final handoff provides the populated block and confirms retrieval of the final commit in this public repository. This reusable template omits its own commit SHA; obtain it with `git rev-parse HEAD` in a checkout of the reviewed commit or copy the commit URL from GitHub.

```text
P0 commit: https://github.com/DavidBraun777/WeatherForge-Warehouse/commit/[FULL_COMMIT_SHA]
Proposal: docs/p0-feasibility.md
Source/provider: NOAA/NCEI Storm Events Database, through BigQuery public data
Dataset: bigquery-public-data.noaa_historic_severe_storms
Verified table: bigquery-public-data.noaa_historic_severe_storms.storms_2024
Instructor access: Public repository; no collaborator invitation required
Question for review: Is this historical 2024 Minnesota dashboard for insurance preparedness a useful and manageable semester scope, with event-grain validation in P1 and live alerts/claims forecasting reserved for later WeatherForge work?
```

## Prior work and attribution

This separate SEIS 732 repository builds on experience with NOAA ingestion, cleaning, normalization, and analytics preparation from [WeatherForge](https://github.com/DavidBraun777/WeatherForge). That collaborative SEIS 745 project credits **David Braun, Odin Lee, and Jannah ElNemr** in the [case study](https://www.dbraun.io/case-studies/weatherforge). This P0 adds new BigQuery profiling and evidence; it imports no earlier graded deliverables, data files, or Git history. A future StormIQ application is outside this P0.

Credit [NOAA/NCEI](https://www.ncei.noaa.gov/access/storm-events-database/) for the source data and Google for its BigQuery distribution. Store only metadata and aggregate evidence here. AI/tool assistance and performed checks are disclosed in [proposal section 9](docs/p0-feasibility.md#9-aitool-accountability).