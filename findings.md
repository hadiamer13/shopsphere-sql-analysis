# ShopSphere SQL Analysis: Findings

**Author:** Hadi Amer  |  **Dataset:** 2,000 customers, 40 products, 24,197 orders, 45,769 order lines (Jul 2024 - Jun 2026)

Each question follows the same template: **Result** (the number), **Meaning** (what it says about the business) and **Action** (what to do about it).

## Conventions used throughout
- **Today** = 1 July 2026 (`DATE '2026-07-01'`).
- **Valid orders** = status `delivered`, `shipped` or `processing`. Cancelled and returned orders are excluded from all revenue figures (Q8, Q10-Q16, Q19, Q20).
- **All orders** (any status) are used where the question is about behaviour rather than revenue: Q3, Q5, Q7, Q9, Q13, Q17, Q18.
- Revenue = `quantity * unit_price` from `order_items` (the price actually charged, after promo discounts). Q6 uses list prices from `products`.
- The data is generated, so patterns such as the very high repeat rates in late cohorts reflect how it was built and should not be read as real-world retention.

---

## Beginner tier

### Q3. Which customers have not ordered in 90+ days?
**Method:** latest order per customer with `MAX(order_date)`, filtered with `HAVING` to last orders before 2 April 2026.
- **Result:** 290 customers (15.8% of the 1,840 who have ever ordered). The most lapsed is customer 1444: last order 19 Mar 2025, 469 days ago, 7 lifetime orders. The ten most lapsed customers placed 3-8 orders each.
- **Meaning:** nearly one buyer in six has gone quiet, and many were repeat buyers, so these are lapsed regulars rather than one-time shoppers.
- **Action:** use this list for the first win-back email campaign, starting with customers who have the most lifetime orders.
- **Caveat:** customers who never ordered are not in `orders`, so they are handled in Q14b.

### Q4. How is the customer base split by region and segment?
**Method:** `GROUP BY region, segment` on `customers`.
- **Result:** Consumers are 60.7% of the 2,000 customers (1,214). Central (699) and South (508) hold 60% of all customers; Highlands is the smallest region (118). Consumers are 56-66% of every region and Corporate is the smallest segment in all five.
- **Meaning:** the base is consistent across regions, with the volume sitting in Central and South.
- **Action:** concentrate campaign budget on Central and South, and run Corporate offers separately because that group is small (35-110 per region).

### Q5. What does the order status breakdown look like?
**Method:** order counts per status divided by total orders (`100.0 * COUNT(*) / (SELECT COUNT(*) ...)`).
- **Result:** 90.9% delivered (22,002), 4.4% cancelled (1,054), 3.1% returned (740), 1.7% shipped (401).
- **Meaning:** about 7.4% of orders (1,794) earn no revenue but still cost payment fees and logistics. The shipped orders are recent and will mostly become delivered.
- **Action:** investigate cancellations first, since they are the larger of the two (regional comparison in Q13).

### Q6. Which categories have an average list price above $30?
**Method:** `AVG(unit_price)` per category from `products`, `HAVING avg > 30`.
- **Result:** Electronics $178.31 (8 products), Sports $36.41 (6) and Home & Kitchen $31.93 (8).
- **Meaning:** Electronics is far above everything else, and Home & Kitchen only just clears the line. Books, Beauty and Toys all average under $30.
- **Action:** set free-shipping thresholds for these three premium categories above those of the low-ticket ones.

### Q7. How often were promo codes used in 2025?
**Method:** 2025 orders with a date range filter, `COALESCE(promo_code, 'No promo')`, share of total. All statuses count because a cancelled order still used the code.
- **Result:** 79.9% of 11,261 orders used no promo (8,996). SAVE10 led with 803 (7.1%), then HOLIDAY 613 (5.4%), WELCOME 553 (4.9%) and FREESHIP 296 (2.6%).
- **Meaning:** about one order in five used a code. SAVE10 and HOLIDAY (1,416 orders, 12.6%) both give 10% off, so they carry the margin cost.
- **Action:** review whether SAVE10 needs to run all year, since HOLIDAY already covers the peak season. FREESHIP is rarely used and could be dropped or tested in another form.

---

## Intermediate tier

### Q8. What is the average order value per segment?
**Method:** CTE at order grain (one row per valid order with `SUM(quantity * unit_price)`), joined to `customers`, then averaged by segment. This avoids averaging line values by mistake.
- **Result:** Small Business $201.16, Consumer $191.65, Corporate $187.36. Consumers still dominate volume: 13,663 of 22,403 valid orders and $2.62M of $4.33M revenue (60.5%).
- **Meaning:** the AOV gap between best and worst segment is only about 7%, and Corporate has the lowest order value rather than the highest.
- **Action:** use similar acquisition-cost limits for all three segments. If Corporate is a strategic aim, it needs a push on bulk or higher-value orders.

### Q9. Which products are bought together?
**Method:** self-join of `order_items` on `order_id` with `a.product_id < b.product_id` so each pair is counted once, joined to `products` for names.
- **Result:** earbuds + charging case appears in 678 orders (2.8% of all orders), then laptop + sleeve (476), smartphone + screen protector (386) and smart watch + strap pack (347).
- **Meaning:** all ten top pairs are a main item plus its natural accessory, and the four Electronics pairs lead.
- **Action:** pre-build bundles and show the accessory at checkout. Accessories earn very little on their own (Q19), so bundling is where they gain sales.

### Q10. What is the month-over-month revenue growth?
**Method:** monthly revenue CTE, self-joined to the previous month with a `LEFT JOIN` so the first month is kept. (The window-function alternative is `LAG`, as used in Q17.)
- **Result:** revenue rose from $43.9k (Jul 2024) to $384.1k (Jun 2026), about 8.7x. November 2024 jumped +146.7%. December 2025 was the peak ($391.0k). January falls sharply after each peak (-41.4% in 2025, -46.5% in 2026).
- **Meaning:** growth is steady underneath a very strong Q4 cycle, and the January floor rises each year.
- **Action:** plan stock, staffing and ad spend around Oct-Dec, and run a January retention campaign to soften the drop.

### Q11. How did revenue by category evolve across 2025?
**Method:** three-table join, valid 2025 orders, `SUM(...) FILTER (WHERE EXTRACT(QUARTER ...) = n)` for one column per quarter.
- **Result:** Q4 brought $860.6k of the year's $2.04M (42.2%). Electronics earned $626.1k in Q4, which is 72.8% of all Q4 revenue and almost double its Q3 ($323.7k). Every category grows each quarter, and Q4 is 2.4-2.9x Q1 everywhere.
- **Meaning:** the holiday peak lifts every category, but Electronics carries it.
- **Action:** stock Electronics, especially laptops and smartphones (Q19), before October, and time seasonal marketing for other categories on the same curve.

### Q12. Which customers spend more than average?
**Method:** lifetime spend per paying customer in a CTE, compared to the average with a subquery.
- **Result:** 704 of 1,840 paying customers (38.3%) spend more than the $2,352.29 average and generate 67.6% of revenue.
- **Meaning:** the other 1,136 customers (61.7%) contribute only 32.4%, so revenue depends on a minority of high spenders.
- **Action:** create a loyalty or VIP programme for these 704 customers and monitor them for churn (Q3, and the At Risk group in Q20).

### Q13. Do cancellation and return rates differ by region?
**Method:** `COUNT(*) FILTER (WHERE status = ...) / COUNT(*)` per region, all orders.
- **Result:** cancellation rates range from 4.16% (West) to 4.55% (South), and return rates from 2.91% (Central) to 3.27% (North).
- **Meaning:** all five regions are within about 0.4 percentage points. Smaller regions (Highlands 1,345 orders, West 2,257) can swing by that much by chance, so no region has a real problem.
- **Action:** do not launch region-specific fixes. Treat cancellations (about 4.4% overall) as a company-wide issue and look at causes by product or promo code. Keep watching South, which is highest.

### Q14. Which products never sold, and which customers never ordered?
**Method:** (a) products with no valid order lines, (b) `NOT EXISTS` on `orders`, grouped by signup year.
- **Result:** (a) one product, the Vintage Typewriter Ribbon (Books, $6.49). (b) 160 customers (8% of 2,000) never ordered: 96 signed up in 2024, 48 in 2025 and 16 in 2026.
- **Meaning:** dead stock is minimal. Most never-buyers have been registered for a long time, so they are cheap but not instant to win over; the 2026 group is still new.
- **Action:** delist the ribbon or give it away as a free add-on once as a test. Send a first-order offer (such as WELCOME) to the 160 non-buyers, starting with the 2024 signups.

---

## Advanced tier

### Q15. Who are the top 3 customers by lifetime value in each region?
**Method:** lifetime value CTE, `RANK() OVER (PARTITION BY region ORDER BY lifetime_value DESC)`, plus regional share with `SUM(...) OVER (PARTITION BY region)`. `RANK` keeps ties, so a region could return more than three rows, but none did here.
- **Result:** the highest customer overall is Omar Mirza (North, $33,567). Each region's number-one customer holds 1.3-5.4% of its region (highest: Rabia Malik in Highlands, 5.41%), and the top 3 together hold 3.4% (South) to 11.1% (Highlands).
- **Meaning:** no single customer carries a region, so key-account risk is low. Highlands and West depend slightly more on their top few because they are smaller.
- **Action:** assign each region's top 3 a named account manager or VIP offer.

### Q16. What is the rolling 3-month average of revenue?
**Method:** monthly revenue CTE, `AVG(...) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`, with a `COUNT(*)` over the same frame to show how many months each average uses.
- **Result:** the rolling average smooths the holiday spike (Jan 2025: $147.4k against a Dec 2024 peak of $177.7k) and bottoms at $111.1k in Mar 2025. By June 2026 it is about $346k, above the $287k it reached at the Dec 2025 peak.
- **Meaning:** the smoothed trend in mid-2026 is higher than the level of the holiday peak itself, so growth is real and not only seasonal.
- **Action:** judge targets and campaigns on the rolling average, not single months. Ignore the first two months for trend work, because they use fewer than 3 months (`months_in_frame` = 1 and 2).
- **Caveat:** every month has data here; in other datasets a complete month calendar would be needed first.

### Q17. What is the time gap between each customer's orders?
**Method:** `order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id)`, aggregated for customers with 5+ orders. `COUNT(days_since_prev)` counts gaps, since each customer's first order has a NULL gap. Segment summary uses `PERCENTILE_CONT(0.5)`.
- **Result:** 1,778 of 1,840 customers (96.6%) have 5+ orders. Customer 10 orders every 0.8 days on average (54 orders) and customer 1 every 2.8 days (221 orders). By segment the median gap is 19 days for Consumer and Small Business and 21 for Corporate; the averages are 35-36 days.
- **Meaning:** nearly everyone is a repeat buyer. The averages sit about 15 days above the medians because a few long gaps pull them up, so the median is the better guide for a typical customer.
- **Action:** send reminders about 3 weeks after an order, using the same timing for all segments. Skip reminders for the heaviest buyers, who return every few days on their own.

### Q18. What share of new customers buy again within 90 days?
**Method:** `ROW_NUMBER()` and `LEAD(order_date)` per customer, keep `seq = 1`, group by first-order quarter. Cohorts with a first order after 31 March 2026 are excluded (85 customers) because they have not had 90 days yet. A second order on the same day counts as a repeat.
- **Result:** 80.4% of the 1,755 customers in the seven complete cohorts bought again within 90 days (1,411). The rate ranges from 69.9% (2024-Q3, 525 customers) and 72.1% (2025-Q1) to 97.3% (2025-Q4) and 98.5% (2026-Q1).
- **Meaning:** early repeat buying is strong overall. The rising rate in late cohorts is partly a data effect: cohorts shrink from 525 to 130 customers and the data is generated, so it does not prove retention improved.
- **Action:** treat the first 90 days as the key window. Send a second-order nudge around day 20-30 (Q17 cadence), and track the 2026-Q2 cohort once its 90 days are complete.

### Q19. What is each product's revenue rank and share within its category?
**Method:** revenue per product CTE, `DENSE_RANK() OVER (PARTITION BY category ...)`, share with `SUM(...) OVER (PARTITION BY category)`, cumulative share as a running sum (Pareto view). 39 products appear because the ribbon never sold.
- **Result:** every category has one hero: Laptop (54.4% of Electronics), Remote Control Car (39.6% of Toys), Perfume 100ml (39.2% of Beauty), Running Shoes (38.5% of Sports), Mystery Novel Box Set (35.6% of Books) and Air Fryer (33.9% of Home & Kitchen). The top two products make up 49-80% of each category, and accessories sit at the bottom (for example Phone Screen Protector 0.6%, Air Fryer Liners 3.1%).
- **Meaning:** revenue is concentrated in a few products per category, and a supply or price problem on one hero would hit the business hard, mostly in Electronics.
- **Action:** protect stock and pricing for the heroes, bundle the tail items with them (Q9), and review the lowest-share products for removal.
- **Caveat:** this covers all valid orders over the whole period, while the 71% Electronics share in the README is 2025 only (Q11).

### Q20. Segment customers with an RFM model.
**Method:** per customer recency (days before 1 July 2026), frequency (distinct orders) and monetary value (revenue), scored with `NTILE(4)` so 4 is always best (recency sorted descending). Rules, checked against the self-check row:
- 1 Champions: R=4, F>=3, M>=3
- 2 Loyal: R>=3, F>=3
- 3 Potential Loyalists: R>=3, F<=2
- 4 At Risk: R<=2, F>=3
- 5 Hibernating: R=2, F<=2
- 6 Lost: R=1, F<=2

| Segment | Customers | Avg recency (days) | Avg orders | Avg spend | % of revenue |
|---|---|---|---|---|---|
| 1 Champions | 213 | 4 | 21.5 | $4,434 | 21.8 |
| 2 Loyal | 324 | 15 | 16.4 | $3,001 | 22.5 |
| 3 Potential Loyalists | 383 | 12 | 7.6 | $1,444 | 12.8 |
| 4 At Risk | 383 | 65 | 15.0 | $2,929 | 25.9 |
| 5 Hibernating | 203 | 46 | 7.8 | $1,482 | 7.0 |
| 6 Lost | 334 | 138 | 6.9 | $1,304 | 10.1 |

- **Result:** Champions and Loyal are 29.2% of customers (537) but 44.3% of revenue. At Risk is 20.8% of customers (383) and 25.9% of revenue, with an average of 15 orders and a last order about 65 days ago.
- **Meaning:** At Risk customers used to buy as often as Loyal ones, but have gone quiet; at 65 days on average, most are still under the 90-day lapse line used in Q3, so there is time to reach them.
- **Action:** target At Risk with win-back offers first, reward Champions with early access and loyalty perks, nudge Potential Loyalists toward a second and third order, and treat Lost customers (138 days) as a low-cost last attempt.
- **Caveat:** segment rules are my own and documented above, and `NTILE` splits tied scores arbitrarily, so counts can differ by a few customers from other rule sets.
