# ShopSphere E-commerce Analysis (SQL)

**Author:** Hadi Amer

## Summary
Answered business questions for a fictional e-commerce company, ShopSphere, using PostgreSQL. The analysis covers customer behaviour, product performance, revenue trends and customer segmentation, based on 2,000 customers, 40 products, 24,197 orders and 45,769 order lines (Jul 2024 - Jun 2026). Every question has its own query in `/queries`, and results were checked against the manual's self-check values.

## Key findings
1. **Revenue grew about 8.7x in two years, with a strong Q4 peak.** Monthly revenue rose from $43.9k (Jul 2024) to $384.1k (Jun 2026). December 2025 was the peak ($391.0k) and Q4 produced about 42% of 2025 revenue. January falls sharply after each peak (-41.4% in 2025, -46.5% in 2026), but the floor rises each year. *Action:* plan stock, staffing and marketing around Oct-Dec, and run a January retention campaign.
2. **Revenue depends on a few products, mainly one.** Electronics made 71% of 2025 revenue ($1.46M of $2.04M), and the 14-inch Laptop alone is 54.4% of Electronics (all valid orders). The top two products make up 49-80% of every category, and accessories each earn under 2% of Electronics revenue. The Vintage Typewriter Ribbon never sold. *Action:* protect laptop and smartphone supply, and review or bundle the tail products.
3. **Every top product pair is a main item plus its accessory.** Earbuds + charging case leads with 678 orders, then laptop + sleeve (476) and smartphone + screen protector (386). *Action:* offer pre-built bundles and "frequently bought together" prompts at checkout, with the cheap accessory shown first.
4. **Revenue is concentrated, and a valuable group is drifting away.** 704 of 1,840 paying customers (38%) generate 67.6% of revenue, and 290 customers have not ordered in over 90 days. The RFM model flags 383 "At Risk" customers (about 15 orders and $2,929 spend each, last order ~65 days ago) who account for 25.9% of revenue. *Action:* target At Risk customers with win-back offers first, then the 290 lapsed customers.
5. **Customers reorder quickly, in every segment.** The median gap between orders is 19-21 days (averages 35-36 days). 69.9% of the 2024-Q3 cohort bought again within 90 days. *Action:* send the first reminder about 3 weeks after an order, using one cadence for all segments.

## Assumptions and caveats
- "Today" is **1 July 2026** (`DATE '2026-07-01'`) for recency questions (Q3, Q20) and for the 90-day cutoffs.
- **Valid orders** = status `delivered`, `shipped` or `processing`; cancelled and returned orders are excluded. Used for revenue-based questions (Q8, Q10-Q16, Q19, Q20).
- **All orders** (any status) are used where the question is about behaviour, not revenue: Q3, Q5, Q7, Q9, Q13, Q17, Q18.
- Q3 treats "inactive" as more than 90 days since the last order (last order before 2 April 2026). Q17 covers only customers with 5+ orders.
- Q18 counts a second order within 90 days of the first as a repeat (a same-day second order counts), and leaves out the 2026-Q2 cohort because it has not had a full 90 days. Later cohorts are small (130-150 customers) and the data is generated, so the rising repeat rate should not be read as improved retention.
- RFM (Q20) uses NTILE(4) scores. Champions = recent (R=4), frequent (F>=3) and high spend (M>=3). Ties are split arbitrarily by NTILE, so counts can differ by a few customers.
- Q3 and Q20 define inactive customers differently, so their group sizes are not expected to match.

## Skills demonstrated
JOINs and self-joins, anti-joins, subqueries, CTEs, window functions (RANK, DENSE_RANK, LAG, LEAD, NTILE, ROW_NUMBER, rolling averages), conditional aggregation with FILTER, percentile calculations, cohort analysis, RFM segmentation.

## Repository structure
```
/queries     Q3.sql ... Q20.sql (plus Q14b.sql and Q17b.sql)
README.md
findings.md   full write-up for every question (Q3-Q20)
```

## Reproduce
1. Open the ShopSphere SQL Lab (HTML file) in a recent Chrome, Edge or Firefox browser. It loads PostgreSQL and builds the dataset automatically. Check the row counts: 2000 / 40 / 24197 / 45769.
   - Alternative: create a PostgreSQL database `shopsphere` and run `shopsphere_setup.sql`.
2. Run any file in `/queries`. Full write-ups are in `findings.md`.
