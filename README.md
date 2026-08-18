# Subscription Churn & June 2026 Price Analysis

## Executive Summary

This project investigates a sharp increase in subscription churn reported for June 2026 and tests whether the **₹399 → ₹449 monthly price increase on 1 June 2026** was responsible.

The initial dashboard headline suggested that monthly churn increased from approximately **4.5% in May to nearly 17% in June**.

I did not accept that headline without verification.

Using the stated churn definition and restricting the analysis to **paid monthly subscribers**, I found:

| Metric | Result |
|---|---:|
| May 2026 monthly churn | **3.7%** |
| June 2026 monthly churn | **11.2%** |
| June churned subscribers | **914** |
| Largest June churn cohort | **March 2026** |
| March cohort June churn | **572** |
| March share of June churn | **62.6%** |
| June churn excluding March cohort | **5.3%** |
| Monthly price | **₹399 → ₹449** |

### Bottom line

**Do not roll the price back based on the June churn spike alone.**

The June spike is heavily concentrated in the **March 2026 acquisition cohort**, which accounts for **572 of 914 June churners (62.6%)**. Excluding that cohort reduces June churn from **11.2% to 5.3%**.

The March cohort is also associated with the **LAUNCH60 acquisition promotion**. The timing indicates that these customers reached the end of their promotional period and their first full-price billing point around the period in which many of their subscriptions ended in June.

This provides a more specific mechanism for the June concentration than simply attributing the entire spike to the June 1 price increase.

The ₹399 → ₹449 price change should therefore be evaluated using customers who were actually exposed to the new price at renewal, rather than using June churn as a whole.

---

# 1. Business Question

The business question was:

> Monthly churn reportedly increased from approximately 4.5% in May to nearly 17% in June after the monthly price increased from ₹399 to ₹449 on 1 June. Should the company roll the price back?

The analysis was designed to answer three questions:

1. **Was the reported June churn actually 17%?**
2. **What specifically drove the June increase?**
3. **Does the evidence justify rolling the price back to ₹399?**

---

# 2. Data

The analysis uses three CSV datasets from the subscription app.

## `users.csv`

| Column | Description |
|---|---|
| `user_id` | Unique user identifier |
| `signup_date` | User signup date |
| `acquisition_channel` | Customer acquisition source |
| `country` | Customer country |

## `subscriptions.csv`

| Column | Description |
|---|---|
| `subscription_id` | Subscription identifier |
| `user_id` | Customer identifier |
| `plan` | Subscription plan |
| `is_trial` | Indicates trial subscription |
| `started_at` | Subscription start timestamp |
| `price_inr` | Price associated with the subscription |
| `promo_code` | Promotion applied |
| `cancelled_at` | Time when the customer clicked cancel |
| `ended_at` | Time when subscription access actually stopped |
| `status` | Subscription status |

## `plans.csv`

| Column | Description |
|---|---|
| `plan` | Plan name |
| `billing_period` | Billing frequency |
| `list_price_inr` | Listed price |
| `effective_from` | Date the price became effective |

---

# 3. Important Data Definitions

Two dates in the subscription data have different meanings.

### `cancelled_at`

The timestamp when the customer clicked **Cancel** in the application.

### `ended_at`

The timestamp when the customer's access actually stopped, at the end of the period they had already paid for.

Therefore:

> **Churn is measured using `ended_at`, not `cancelled_at`.**

---

# 4. Trial Handling

The 14-day free trial creates its own subscription row.

A trial that subsequently converts also creates subscription records.

Therefore, trials are excluded from the churn calculation.

The official churn population is:

```text
is_trial = 0
plan = monthly
```

---

# 5. Churn Definition

The challenge defines monthly churn as:

```text
Monthly churn rate
=
Subscriptions whose access ended during the month
/
Subscriptions active at the first instant of that month
```

Only **paid monthly subscribers** are included.

For June:

```text
Numerator:
ended_at >= 2026-06-01
AND
ended_at < 2026-07-01

Denominator:
started_at < 2026-06-01
AND
(ended_at IS NULL OR ended_at >= 2026-06-01)
```

---

# 6. Verified Answers

| # | Question | Answer |
|---|---|---|
| 1 | June 2026 monthly churn | **11.2%** |
| 2 | May 2026 monthly churn | **3.7%** |
| 3 | Signup-month cohort with most June churn | **2026-03** |
| 4 | March cohort subscribers ending in June | **572** |
| 5 | June churn excluding March cohort | **5.3%** |

### June 2026

**11.2%**, not the reported ~17%.

### May 2026

**3.7%** using the same definition.

### Largest June churn cohort

**March 2026.**

### March cohort June churn

**572 subscribers**, or **62.6% of the 914 June churners**.

### June churn excluding March

**5.3%**, after removing the March cohort from both numerator and denominator.

---

# 7. What Actually Drove June?

The June spike was **not evenly distributed across all customers**.

It was heavily concentrated in the March 2026 signup cohort.

```text
June churn
    │
    ├── March 2026 cohort
    │       572 subscribers
    │       62.6% of June churn
    │
    └── Other cohorts
            remaining June churn
```

Removing March reduces churn from **11.2% to 5.3%**.

This means that simply looking at blended month-over-month churn hides the main driver.

---

# 8. The March Acquisition and LAUNCH60 Mechanism

The company ran an acquisition campaign in March.

The March cohort was associated with the **LAUNCH60 promotion**.

The relevant sequence is:

```text
March acquisition campaign
          ↓
LAUNCH60 promotion
          ↓
Large March signup cohort
          ↓
Promotional period reaches its end
          ↓
First full-price billing point
          ↓
Customers cancel / subscriptions reach access end
          ↓
Large concentration of access endings in June
```

This provides a more specific explanation for why the March cohort produced so many June churn events.

The key point is not that LAUNCH60 proves every customer churned because of the promotion ending.

Rather:

> **The timing and cohort concentration identify the end of the promotional/full-price transition as a plausible mechanism behind the June access-ending concentration.**

---

# 9. Why the Price Increase Is Not Yet Proven to Be the Cause

The monthly price increased:

```text
₹399 → ₹449
```

on **1 June 2026**.

However, June churn is defined using `ended_at`, and many subscriptions ending in June were started before 1 June.

Therefore, June churn is not a clean experiment measuring the response to the new ₹449 price.

The two events overlap:

```text
March LAUNCH60 cohort
        ↓
Promotional period / first full-price billing
        ↓
June access endings
```

while simultaneously:

```text
1 June
₹399 → ₹449 price change
```

Because these effects are not cleanly separated in June, the 11.2% churn rate cannot be interpreted as:

> "Customers saw ₹449 and therefore churned."

That would be an unsupported causal conclusion.

---

# 10. Testing the Price Hypothesis

The correct question is:

> **Did customers actually exposed to ₹449 at renewal churn at a higher rate because of the new price?**

June's overall churn does not answer that question cleanly.

A better pricing analysis would compare:

```text
Customers exposed to ₹449 at renewal
                VS
Comparable customers previously exposed to ₹399
```

and measure:

- Renewal rate
- Churn rate
- Cancellation rate
- Revenue per subscriber

---

# 11. Recommendation: Do Not Roll Back ₹449

### **Keep ₹449 for now.**

Rolling the price back would sacrifice revenue based on a June churn spike that is not cleanly attributable to the price increase.

The evidence shows:

```text
May churn                       3.7%
June churn                     11.2%
March cohort share of June     62.6%
June churn excluding March      5.3%
```

The June increase is heavily concentrated in the March cohort.

That cohort was associated with the LAUNCH60 acquisition campaign and reached the promotional/full-price transition around the time of the June access endings.

The evidence does **not** establish that ₹449 caused the entire June spike.

Therefore:

> **Do not roll back the price based on June churn alone.**

Instead, measure actual renewal and churn among customers who were exposed to ₹449.

---

# 12. Recommended Next Analysis

Track customers whose first renewal was actually priced at ₹449.

Measure:

- Renewal rate
- Churn rate
- Cancellation rate
- Revenue per subscriber
- Revenue retained after churn

Then compare against a comparable pre-price cohort that renewed at ₹399.

Decision rule:

```text
If additional revenue from ₹449
>
Revenue lost from incremental churn
        ↓
Keep ₹449

If revenue loss from incremental churn
>
Revenue gained from price increase
        ↓
Reconsider pricing
```

---

# 13. Power BI Dashboard

The Power BI dashboard was built to make the analysis easy to verify visually.

## KPI Cards

- **May Monthly Churn — 3.7%**
- **June Monthly Churn — 11.2%**
- **June Churned — 914**
- **March Cohort June Churn — 572**
- **June Churn Excluding March — 5.3%**
- **Monthly Price — ₹399 → ₹449**

## Monthly Churn Trend

A line chart shows monthly paid-monthly churn across the available period.

**Purpose:** Establish that June is an unusual spike.

## June Churn by Signup Cohort

A column chart groups June churners by subscription start month.

**Purpose:** Identify the cohort that drove June churn.

The March 2026 cohort is the dominant contributor.

## March Acquisition Mix

A donut chart shows acquisition channels among March signups.

**Purpose:** Provide context for the March acquisition campaign and cohort composition.

## June Churn by Starting Price

A column chart shows June churned subscriptions by recorded starting price.

**Purpose:** Describe the price composition without incorrectly claiming price caused churn.

## Overall June Churn vs Excluding March

```text
All June cohorts          11.2%
Excluding March            5.3%
```

**Purpose:** Demonstrate how much of the June spike is concentrated in the March cohort.

---

# 14. SQL Analysis

The SQL analysis is organized into:

```text
sql/
├── 03_data_quality.sql
├── 04_churn_analysis.sql
├── 05_cohort_analysis.sql
├── 06_campaign_price_analysis.sql
└── 07_launch60_mechanism.sql
```

### `03_data_quality.sql`

Checks the source data and subscription structure.

### `04_churn_analysis.sql`

Calculates May and June churn using the official definition.

### `05_cohort_analysis.sql`

Breaks June churn down by signup cohort and isolates the March effect.

### `06_campaign_price_analysis.sql`

Investigates acquisition channels, pricing, and the relationship between the June churn spike and the price change.

### `07_launch60_mechanism.sql`

Investigates the March LAUNCH60 cohort and the timing of its June access endings to establish the promotional/full-price mechanism.

---

# 15. Data Quality Considerations

### Trials

Trials are excluded from the paid subscriber population.

### Cancellation vs access end

`cancelled_at` is not used as the churn date.

`ended_at` is used because it represents when access actually stopped.

### Duplicate subscription IDs

The subscription table can contain multiple rows for the same `subscription_id`.

The analysis therefore does not assume:

```text
subscription_id = unique row
```

The raw table uses:

```text
subscription_row_id
```

as the physical row identifier.

This is important because a subscription can generate multiple subscription records over its lifecycle, including trial/conversion behavior.

---

# 16. Tools Used

- **MySQL** — data loading, cleaning and analysis
- **SQL** — churn calculations, cohort analysis and mechanism testing
- **Power BI** — dashboard and executive visualization
- **Git/GitHub** — version control and project documentation

---

# 17. Repository Structure

```text
subscription-churn-price-analysis/
│
├── README.md
│
├── powerbi/
│   └── Subscription_Churn_Analysis.pbix
│
├── results/
│   └── five_verified_answers.md
│
└── sql/
    ├── 03_data_quality.sql
    ├── 04_churn_analysis.sql
    ├── 05_cohort_analysis.sql
    ├── 06_campaign_price_analysis.sql
    └── 07_launch60_mechanism.sql
```

---

# 18. Final Answer to the Business

## Should the company roll the price back from ₹449 to ₹399?

### **No — not based on the June churn spike alone.**

The verified June churn rate is **11.2%**, not ~17%.

The increase from May's **3.7%** is heavily concentrated in the March 2026 acquisition cohort, which generated **572 of 914 June churners (62.6%)**.

The March cohort was associated with the **LAUNCH60 acquisition campaign**, and the timing of the cohort's promotional/full-price transition provides a plausible mechanism for the concentration of June access endings.

When the March cohort is removed from both the numerator and denominator, June churn falls to **5.3%**.

Therefore, June does not provide a clean causal test of the **₹399 → ₹449** price change.

**Keep ₹449 for now.**

The next decision should be based on actual renewal and churn behavior among customers who were exposed to the ₹449 price at renewal, compared with a comparable pre-price cohort.

---

# 19. Conclusion

The main lesson from this analysis is that **a blended month-over-month churn metric can hide the actual driver of a spike**.

June looked like a broad pricing problem when viewed only through the headline churn rate.

After validating the metric and segmenting churn by signup cohort, the picture changed:

> **The March acquisition/LAUNCH60 cohort accounts for most of the June churn concentration, and excluding that cohort reduces churn to 5.3%.**

The June 1 price increase may still affect future renewals, but the available June churn data is not sufficient to attribute the spike to ₹449.

**Recommendation: keep ₹449 for now and evaluate the price using actual post-price renewal behavior.**
