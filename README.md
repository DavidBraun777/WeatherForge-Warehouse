# WeatherForge Warehouse

**David Braun · SEIS 732 · P1 draft for peer diagnosis · P0 instructor approval pending**

WeatherForge Warehouse proposes a historical storm-event dashboard for **an insurance analyst responsible for catastrophe preparedness in Minnesota**. County, hazard, and month comparisons would help shortlist historical cases for investigation and preparedness exercises. This is a classroom use-case hypothesis; insurer demand and business benefit have not been validated.

## Current milestone: P1

The [P1 plan](docs/p1-plan.md) defines the event grain, dimensional model, history behavior, and planned Raw → Curated → Serving build. The warehouse and dashboard remain planned.

**Primary question:** Which Minnesota counties had the most distinct reported events for a selected hazard in 2024?

**Supporting question:** How were those events distributed across the months of 2024?

The scope remains **2024**, Minnesota state FIPS **27**, county-coded records (`cz_type = 'C'`), and **hail, thunderstorm wind, tornado, and flash flood**. David's October 28 direction adds a history requirement: show corrected totals and compare them with an earlier captured version.

The proposed model preserves one fact per reported event per successful capture. Repeated source locations do not become additional events. A report selects one published capture; a comparison aggregates two captures separately. Version history will begin with source states the warehouse actually retains.

David's longer-term WeatherForge goals include weather-related alerts and forecasting insurance claims. This semester's contribution is a bounded historical dashboard and trustworthy warehouse foundation. The current source does not establish live conditions, claims, insured exposure, or forecast accuracy.

## Project files

| File | Purpose |
| --- | --- |
| [docs/p1-plan.md](docs/p1-plan.md) | Four required P1 tasks, reused observed grain evidence, model/history decisions, checks, and pending feedback memo |
| [docs/model.svg](docs/model.svg) | Event snapshot fact, dimensions, keys, measures, and relationships |
| [sql/01_source_profile.sql](sql/01_source_profile.sql) | Focused reproduction of the P0 grain check and additional unexecuted diagnostics |
| [docs/p0-feasibility.md](docs/p0-feasibility.md) | P0 proposal and need-to-source fit |
| [sql/00_feasibility.sql](sql/00_feasibility.sql) | Original read-only Q1–Q3 feasibility checks |
| [evidence/p0-feasibility-results.md](evidence/p0-feasibility-results.md) | Recorded BigQuery metadata, results, query jobs, and costs |

## Recorded source evidence

NOAA/NCEI Storm Events is distributed through BigQuery public data. **Codex completed P0 Q1–Q3 on October 21, 2026**, in project `seis-732-david`, location **US**. P1 reuses those dated results; no new BigQuery execution is claimed.

- Verified source: `bigquery-public-data.noaa_historic_severe_storms.storms_2024`; the nine requested fields had the expected types.
- Selected population: **885 source rows / 809 distinct event IDs**, across 80 county codes, four hazards, and April–September 2024.
- **39 event IDs repeat**, with no conflicts in the checked target county-code/hazard/start-time attributes within that subset. These checks support event-level aggregation within the selected population; additional diagnostics remain unexecuted.
- Q3 processed **5.06 MB** and billed **10 MB**, below the **1 GiB** per-query ceiling used for that execution.

Counts describe reported events and observed coverage. They do not prove reporting completeness, rank insured risk, or count independent storm systems. Source rows and distinct event counts remain separate measures.

## Review and submission

David reports reviewing the plan and diagram. As of October 28, David reports **no instructor or peer feedback yet**. P0 approval remains pending. P1 is a draft for peer diagnosis; its final memo must record actual feedback, revisions adopted, revisions not adopted and why, and the remaining uncertainty.

Before submitting P1, complete the feedback memo after diagnosis, commit the revision, and ensure the P1 files are on the branch the instructor will open. Canvas accepts the repository link; include the plan path for clarity:

```text
Repository: https://github.com/DavidBraun777/WeatherForge-Warehouse
P1 plan: docs/p1-plan.md
Model: docs/model.svg
Grain check: sql/01_source_profile.sql
```

The repository is public. No claim is made that the instructor has approved the scope or reviewed this draft. AI/tool assistance and verification are disclosed in each milestone's plan.

## Prior work and attribution

This separate SEIS 732 repository builds on experience with NOAA ingestion, cleaning, normalization, and analytics preparation from [WeatherForge](https://github.com/DavidBraun777/WeatherForge). That collaborative SEIS 745 project credits **David Braun, Odin Lee, and Jannah ElNemr** in the [case study](https://www.dbraun.io/case-studies/weatherforge). This repository adds new BigQuery profiling and warehouse planning; it imports no earlier graded deliverables, source-data files, or Git history. A future StormIQ application remains outside this semester plan.

Credit [NOAA/NCEI](https://www.ncei.noaa.gov/access/storm-events-database/) for the source data and Google for its BigQuery distribution. Commit SQL, documentation, diagrams, and compact aggregate evidence. Keep source extracts and credentials out of Git.
