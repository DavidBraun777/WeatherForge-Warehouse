# S1 preparation and WeatherForge project review

**David Braun · SEIS 732 · October 29, 2026 (America/Chicago)**

**Status:** Preparation notes and a discussion worksheet. Final S1 choices depend on the M09 analytical request, evaluation criteria, and response template. Those materials were not included in the packet reviewed here.

**Repository baseline:** [`c874756`](https://github.com/DavidBraun777/WeatherForge-Warehouse/tree/c87475608b8ac8356019dca7ceac17ad9dfc22a9). This review uses the existing [P1 plan](p1-plan.md), [model](model.svg), [source-profile SQL](../sql/01_source_profile.sql), and [recorded evidence](../evidence/p0-feasibility-results.md). It adds preparation notes; it does not claim a new BigQuery execution or implemented warehouse.

## 1. How the two assignments connect

WeatherForge is the semester project: historical Minnesota reported-storm analysis for insurance catastrophe-preparedness analysts. The UMT Outdoor Program is the business case for a separate individual modeling sprint.

Use WeatherForge to practice the reasoning that transfers: identify the decision, choose the process, declare what one row means, distinguish source identifiers from warehouse keys, preserve the history the question needs, and prove that joins do not change counts incorrectly. Choose UMT's model from its own request and source records.

| Modeling concern | WeatherForge P1 | UMT preparation case |
| --- | --- | --- |
| Source records versus analytical activity | Multiple location rows may describe one reported event. | An agreement contains multiple checkout records; one physical item can be checked out repeatedly. |
| Grain | One eligible reported event from one annual source table in one complete warehouse capture. | Depends on the request: a rental-item checkout, a completed rental item, a reservation, or a defined time-based measure. |
| Identity | Source `event_id`; fact identity includes `snapshot_id`. | Catalog offering, physical unit, checkout record, agreement, and customer have different IDs. |
| History | Preserve the source state observed at each retained capture. | Membership history states when a customer's category was effective. |
| Dates | Event's reported begin date and warehouse capture timestamp have separate meanings. | Reservation creation, planned pickup, checkout, and return are separate roles. |
| Counting hazard | Repeated locations or combined captures inflate event counts. | Counting agreements as items, packages as components, or repeated reservation quantities inflates measures. |
| Evidence boundary | Reported-event counts do not establish insured risk or expected claims. | Final charges do not establish payments, profit, available capacity, or historical prices. |

A grain declaration is a statement about a business occurrence, not just a list of key columns. Choose it before choosing dimensions and measures. See Kimball's [grain guidance](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/grain/).

## 2. WeatherForge: what is established and what remains

### Established in the current repository

The P1 model already addresses the central modeling problems:

- The recorded October 21 profile contains **885 selected source rows and 809 distinct event IDs**. Thirty-nine IDs repeat, creating 76 additional row occurrences. These are recorded aggregate findings, not a fresh extraction.
- Raw preserves location repetitions. Curated is planned to validate reporting assignments before producing one event contribution per capture.
- The fact key `(snapshot_id, event_id)` works under the stated rule that each snapshot identifies exactly one annual source table.
- The current report selects one complete published capture. An earlier-versus-newer comparison aggregates each capture separately before comparing groups.
- Event reassignment history lives in the captured fact assignments. Type 1 county-label corrections preserve county identity but do not promise exact old label spelling.
- The expected 809 facts apply to the recorded baseline. A later capture must reconcile to its own validated distinct-ID count.
- The October 21 aggregate evidence cannot reconstruct an event-level capture that was never retained.
- Diagnostics, the history experiment, warehouse layers, and dashboard are correctly described as planned where they have not been executed.

These choices are documented in [P1 sections 1–3](p1-plan.md). The main next step is to implement and demonstrate the plan.

### Decisions to resolve before the build

| Decision | Current position | Recommended next action |
| --- | --- | --- |
| Instructor and peer feedback | P1's memo still records feedback and P0 approval as pending. | Add actual comments and the corresponding decisions when available. Submission alone does not establish approval or feedback. |
| County identity and coverage | County-code syntax is checked; an authoritative geographic match has not been performed. Coverage is intentionally the source-represented county set. | Validate the county business keys. Decide whether to retain represented-county coverage or extend the report to a complete Minnesota county reference. Label absence and zero recorded events accurately. |
| Publication-blocking errors | Q2 flags missing scope fields across the entire annual source; P1 expects zero missing scope fields. | Decide whether definitely unrelated rows should block the Minnesota report. Keep the diagnostic, but consider separating definitely outside-scope anomalies from unresolved eligibility and eligible-record defects. |
| Retry behavior | The planned run order protects publication, but retry mechanics are not implemented. | Define how failed runs receive or reuse a capture ID, prevent duplicate fact keys, and select the latest published capture deterministically. |
| Demonstrated history | Synthetic correction, removal, and failed-run behavior are planned. | Execute the bounded fixtures and retain their results. Clearly separate synthetic demonstrations from observed NOAA changes. |
| Fact-type terminology | P1 uses an event-level snapshot with captures taken when extraction runs. | Be able to explain that grain and behavior. Do not assume an irregular captured version is automatically a conventional periodic snapshot. |

**A concrete quality-gate example:** If a source row has a known non-Minnesota state code but a missing hazard, the state already excludes it from the Minnesota population. Blocking the Minnesota report for that row is a stricter policy than protecting the selected analytical result. This is a proposed policy refinement, not an observed defect in the recorded source. Unknown eligibility and defects in eligible records still need resolution.

### A bounded build sequence

1. Obtain the actual next-milestone requirements and relevant instructor feedback.
2. Confirm schema and query estimates, then retain a complete Raw capture with its capture metadata.
3. Run all downstream checks against that captured data. Resolve the county and publication-gate decisions.
4. Build dimensions and one event fact per eligible ID in the capture. Check unique fact keys, exactly one dimension match per fact, and count reconciliation.
5. Publish one validated capture, expose its county/hazard/month summaries, and demonstrate the existing synthetic history scenarios.

This sequence does not require adding a new orchestration platform. The current scope remains the 2024 Minnesota retrospective with four hazards; live alerts and claims forecasts remain longer-term goals.

## 3. UMT business preparation

The [UMT equipment-rental page](https://www.umt.edu/crec/Outdoor/equipment.php) lists Boating, Camping, Climbing, Biking, and Winter equipment. Member rates apply to current Campus Recreation members with valid Griz Cards. Reservations and same-day rentals are offered, subject to availability.

The retrieved page agrees with the four catalog examples in the supplied packet:

| Offering | Category | Member daily price | Non-member daily price |
| --- | --- | ---: | ---: |
| Two-person, three-season tent | Camping | $14 | $18 |
| Overnight backpack | Camping | $12 | $15 |
| Cross-country ski package | Winter | $20 | $24 |
| Inflatable standup paddleboard package | Boating | $30 | $35 |

For example, the tent's daily non-member price is $4 higher. These prices establish business context. The exercise explicitly uses each checkout record's **final rental charge** for requested calculations; do not replace it with a calculation from the catalog rates.

### Business users, questions, and processes

| Possible decision owner | Possible question | Process or evidence needed |
| --- | --- | --- |
| Program manager | Which categories account for finalized rental charges for a defined period and population? | Completed rental items and a stated reporting-date rule |
| Rental desk manager | How many items remain out at a chosen cutoff? | Checkout/return intervals, a cutoff, and a complete relevant rental population |
| Reservation coordinator | What proportion of requested quantities led to actual checkouts? | Reservations and linked rental-item records at compatible aggregation grains |
| Equipment planner | Which equipment should be purchased or replaced? | Rentals are one input; a defensible investment decision also needs costs, availability, unmet demand, or condition evidence |

**One possible analytical question to bring to class:**

For each checkout month, how do rental-item counts and finalized rental charges vary by equipment category and membership category at checkout, with unfinished rentals reported separately?

This is a practice question. It does not assert what the instructor's released request will be.

**One source/meaning question to bring:**

If the request reports monthly charges, should the month represent checkout, actual return, or a separate charge-finalization event? The supplied fields include checkout and return timestamps but no separate finalization timestamp.

## 4. Understand identity before drawing a model

| Identifier | What it identifies | What it does not identify |
| --- | --- | --- |
| `offering_id`, such as O11 | A catalog type, such as the two-person tent | A particular tent or checkout |
| `rental_unit_id`, such as U11 | One physical rental item or package | Every checkout of that item |
| `rental_item_id`, such as RI101 | One checkout record for one item | A whole multi-item agreement |
| `rental_id`, such as R100 | The agreement containing rental items | Exactly one item |
| `reservation_id` | A catalog request with a quantity | Exactly one resulting checkout |
| `customer_id`, such as C17 | A stable customer identity | A single historical membership version |
| A warehouse customer-version key | One effective-dated customer dimension row, if Type 2 is chosen | A distinct person |

Under the supplied rules, a package counts as one checked-out and charged item. Components have no separate charge in these records. Introducing component rows would require a different supported question and source definition.

A reservation and a rental checkout are different business processes. The fact that both describe equipment does not make their grains interchangeable.

## 5. Choose fact-table behavior from the request

| If the analytical request concerns... | A defensible candidate | What must be explicit |
| --- | --- | --- |
| Finalized charges for completed rentals | One completed rental-item occurrence, with its authoritative final charge | Eligibility for inclusion and the reporting-date role |
| Progress from checkout to return | An accumulating snapshot at rental-item grain | Insert at checkout; update the same row as return and charge become known; open milestones remain incomplete |
| Separate checkout and return activity | Transaction events for the corresponding business occurrences | Event identity and prevention of counting a single charge twice |
| Reservations and requested quantities | One reservation record with `quantity_reserved` | Reservation cohort, status treatment, cutoff, and linkage to checkouts |
| Daily outstanding items | A query derived from complete checkout/return intervals, or a justified daily snapshot | The cutoff and time rules; the daily result does not by itself establish operational availability |

A transaction fact describes an occurrence; an accumulating snapshot follows one process instance as milestones are reached. Multiple date columns alone do not decide the type. The update behavior and analytical purpose matter; correcting or enriching a transaction row does not by itself make that table an accumulating snapshot. See Kimball's [transaction facts](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/transaction-fact-table/) and [accumulating snapshots](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/accumulating-snapshot-fact-table/).

For a completed-rental analysis, likely descriptive context includes catalog offering/category, the appropriate customer version, and the dates required by the question. An agreement ID can remain on the fact for grouping without requiring a dimension containing only that ID. Whether physical units deserve their own dimension depends on the requested analysis and available descriptive attributes.

Do not add all six source tables as dimensions merely because the extracts exist.

## 6. History and time: the important distinction

WeatherForge's capture timestamp says when the warehouse observed a source state. UMT's membership intervals say when a business classification applied. Those are different forms of history.

If the released UMT question requires **membership at checkout**, resolve the customer's history using the actual checkout timestamp:

```sql
r.customer_id = h.customer_id
AND r.checked_out_at >= h.effective_from
AND (
  h.effective_to IS NULL
  OR r.checked_out_at < h.effective_to
)
```

This is conceptual lookup logic using the packet's fields, not executed SQL. The start is included and the end excluded. Using inclusive `BETWEEN` on adjacent closed boundaries could match two versions at a change instant.

If a Type 2 customer dimension is used, give each membership version its own warehouse key, retain the stable `customer_id`, and attach the appropriate version key to each fact. A late load must resolve history using the relevant business timestamp, not whichever customer version happens to be current on load day. See Kimball's [Type 2 guidance](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/type-2/).

For C17:

- A March 30 checkout belongs to the Member interval.
- An April 10 checkout belongs to the Non-member interval.
- A checkout exactly at April 1 midnight belongs only to the Non-member interval.
- A later return does not change the category **at checkout**.
- Counting distinct warehouse version keys would count versions, so use stable customer identity when the question asks for distinct people.

The timestamp for classification and the date used to group the measure are separate decisions. A question could group by return month while still classifying customers by membership at checkout.

The same physical date dimension can serve separate logical roles, such as checkout date and return date. Preserve timestamps for interval matching and exact elapsed-time calculations where required. An unfinished return needs a distinguishable not-yet-returned representation; it should not silently become a real date. See Kimball's [role-playing dimensions](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/role-playing-dimension/).

Catalog name, category, and item/package classification are explicitly stable during this exercise. Do not invent changes or a rate-history extract. Historical rate comparisons would require evidence beyond the supplied catalog.

## 7. Practice checks using the supplied examples

The results below are arithmetic from the four teaching checkout records, not UMT operational findings or a released S1 answer.

| Check | Result | Why |
| --- | ---: | --- |
| Rental-item checkout records | 4 | RI101 through RI104 are four separate occurrences. |
| Agreements | 3 | R100 contains two items; R101 and R102 each contain one. |
| Distinct physical rental units | 3 | U11 is used twice; U12 and U21 once each. |
| Distinct customers | 2 | C17 and C28; membership versions do not create people. |
| Returned and finalized items in the sample | 3 | RI101, RI102, RI103 have both values. |
| Open items in the sample | 1 | RI104 has no return timestamp. |
| Sum of supplied finalized charges | $96 | $42 + $36 + $18. |
| Finalized charges classified by membership at checkout | Member $78; Non-member $18 | March 30 checkouts precede C17's April 1 category change. |
| Average final charge among the three finalized items | $32 | $96 / 3. The open item's unknown final charge is not a zero-dollar observation. |

**Reporting-date test:** The $78 on RI101 and RI102 belongs to a March checkout cohort but an April return cohort. Both are possible analyses; the report must say which one it represents. The records do not supply a separate finalization timestamp or payment date.

**Join test:** Membership resolution must match each rental item once. An ordinary join on `customer_id` alone would multiply C17's checkout rows across both history records. A current-customer join would retain one match but misclassify C17's March checkouts for historical analysis.

**Reservation test — additional synthetic example:** A reservation requests three items and yields three checkout rows. A detail join repeats `quantity_reserved = 3` on all three rows. Summing that repeated field gives 9 requested items even though only 3 were requested. Aggregate checkouts to reservation grain before combining requested and fulfilled quantities. The denominator must also follow the agreed cohort/status/cutoff rule.

**Walk-in test:** A missing reservation ID can represent a valid walk-in rental. A rental analysis that inner-joins reservations would exclude these items. Preserve them unless the requested population explicitly requires a reservation.

**Distinct-count test:** An agreement or customer may occur in more than one category. Summing category-level distinct counts can overstate the distinct total across categories. Recalculate at the requested total's grain.

**Package test:** A ski package contributes one rental item. Its skis, boots, and poles must not multiply the package's recorded charge.

**Null test:** A missing final charge is unknown or unfinished. A real finalized charge of $0 would be a different observation. Report known-charge totals and completion counts explicitly; do not present unfinished charges as measured zero revenue.

## 8. Questions the supplied records cannot fully answer

| Desired analysis | Missing evidence or unresolved meaning |
| --- | --- |
| Overdue rentals or lateness | A promised return/due timestamp and lateness rule are not supplied. Planned pickup is not a return deadline. |
| Profit or return on equipment investment | Purchase, maintenance, labor, depreciation, and other relevant costs are not supplied. |
| True equipment utilization | Checkout intervals support observed rental activity, but historical in-service periods, maintenance, closures, and available-capacity rules are missing. |
| Revenue by payment or exact finalization date | Neither payment timestamp nor a separate finalization timestamp is supplied. Return time should not be silently substituted. |
| Unmet demand | Requests turned away, searches without reservations, waitlists, or stockout records are not supplied. |
| Component-level demand or allocated package revenue | Component checkout lines and an allocation rule are not supplied. |
| Historical price or discount effects | Historical rate versions and applied-discount/billing rules are not supplied. |
| Time spent in reservation statuses | The extract supplies a status but no sequence of status-transition timestamps. |
| Fulfillment or cancellation percentages | Requested quantities and linked checkouts can support defined measures, but the cohort, exclusions, cutoff, and reservation-versus-quantity denominator must be chosen. |

These limits should narrow claims. They do not prevent the source-supported analyses.

## 9. Discussion questions for David

Start with these, answering briefly in your own words:

1. **Feedback:** What did Chandler or your peers actually say about P1, A01, A02, or S0? Paste the comments that affect modeling; the reviewed repository still shows feedback as pending.
2. **S1 materials:** Has the actual analytical request/template been released since this packet, or do we currently have only preparation material?
3. **Grain explanation:** In the UMT sample, how would you explain four checkouts, three agreements, and three physical units to someone who calls all three “rentals”?
4. **History explanation:** If a March checkout returns after the April 1 membership change, which timestamp would you use for “membership at checkout,” and why?
5. **WeatherForge coverage:** Should the dashboard continue to show the source-represented county set, or should a validated complete county reference introduce explicit zero-recorded-event counties?
6. **Publication policy:** Should a definitely out-of-state data defect stop a Minnesota report, or remain a visible diagnostic while defects affecting Minnesota results block publication?

The first two establish what evidence is missing. The next two test the reasoning most likely to transfer to S1. The final two settle concrete project choices.

## 10. Four-part practice worksheet

Fill this after choosing a clearly stated practice request, then revise it against the actual released S1 request.

### A. Process and grain

- Decision owner and decision:
- Business process measured:
- One row represents:
- Inclusion/exclusion rule:
- Fact-table type and why its behavior fits:

### B. Model

- Fact table:
- Source occurrence ID and warehouse uniqueness rule:
- Dimensions and each dimension's grain:
- Foreign-key relationships and expected cardinality:
- Measures, units, and valid aggregation rules:
- Date roles:

### C. History and keys

- Attributes that change:
- History treatment for each:
- Business timestamp used to resolve the relevant historical version:
- Stable identity versus version identity:
- Handling of unfinished values:
- One concrete change example and its reporting consequence:

### D. Explain the answer path

- Filter the analytical population by:
- Resolve/join:
- Group by:
- Aggregate:
- Prevent double counting by:
- Prove the answer with these sample checks:
- State these remaining source limitations:

### Suggested use of the 60-minute work window

| Minutes | Work |
| --- | --- |
| 0–8 | Read the released request and identify owner, decision, measures, population, and dates. |
| 8–18 | Declare the process, grain, fact type, and inclusion rules. |
| 18–33 | Draw the model; label identities, keys, measures, and relationships. |
| 33–45 | Explain history, date roles, nulls, and why the keys preserve meaning. |
| 45–55 | Trace each requested answer through the model and check the examples. |
| 55–60 | Check alignment with the rubric and eliminate unexplained assumptions. |

Orientation and submission time are separate according to the supplied packet.

## Sources and review limits

- S1 preparation packet supplied in the conversation, including its teaching records and explicit interval/package/charge rules.
- [UMT equipment-rental page](https://www.umt.edu/crec/Outdoor/equipment.php), retrieved for business context and member/non-member price comparison.
- WeatherForge [P1](https://github.com/DavidBraun777/WeatherForge-Warehouse/blob/c87475608b8ac8356019dca7ceac17ad9dfc22a9/docs/p1-plan.md), [SQL](https://github.com/DavidBraun777/WeatherForge-Warehouse/blob/c87475608b8ac8356019dca7ceac17ad9dfc22a9/sql/01_source_profile.sql), and [recorded evidence](https://github.com/DavidBraun777/WeatherForge-Warehouse/blob/c87475608b8ac8356019dca7ceac17ad9dfc22a9/evidence/p0-feasibility-results.md) at the baseline commit.
- Kimball Group's primary modeling references linked beside the relevant concepts.

The worksheet contains proposed practice questions and review recommendations. Actual instructor feedback and final S1 requirements remain inputs to be supplied.
