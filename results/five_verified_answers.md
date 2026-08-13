# Five Verified Answers — Subscription Churn Analysis

This file documents the five verified answers submitted for the assessment, including the business definition, SQL logic, calculations, and results.

---

# 1. What was the monthly churn rate in June 2026?

## Definition

The assessment defines monthly churn as:

```text
Churn Rate =
Subscriptions whose access ended during the month
-------------------------------------------------
Subscriptions active at the first instant of that month
```

The analysis uses:

- Paid subscribers only: `is_trial = 0`
- Monthly plan only: `plan = 'monthly'`
- `ended_at` to determine when customer access actually stopped

### Why `ended_at` instead of `cancelled_at`?

`cancelled_at` records when a customer clicked cancel.

`ended_at` records when their access actually stopped.

Therefore, `ended_at` is the correct field for measuring churn under the definition provided.

## SQL

```sql
SELECT
    COUNT(*) AS active_at_start_of_june,

    SUM(
        ended_at >= '2026-06-01'
        AND ended_at < '2026-07-01'
    ) AS ended_in_june,

    ROUND(
        100 * SUM(
            ended_at >= '2026-06-01'
            AND ended_at < '2026-07-01'
        ) / COUNT(*),
        1
    ) AS churn_rate

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND started_at < '2026-06-01'
  AND (
      ended_at IS NULL
      OR ended_at >= '2026-06-01'
  );
```

## Calculation

Paid monthly subscriptions active at the beginning of June:

**8,183**

Paid monthly subscriptions whose access ended during June:

**914**

```text
914 / 8,183 × 100
= 11.17%
```

Rounded to one decimal place:

### Answer: **11.2%**

---

# 2. What was the monthly churn rate in May 2026?

The same definition and population were used for May.

## SQL

```sql
SELECT
    COUNT(*) AS active_at_start_of_may,

    SUM(
        ended_at >= '2026-05-01'
        AND ended_at < '2026-06-01'
    ) AS ended_in_may,

    ROUND(
        100 * SUM(
            ended_at >= '2026-05-01'
            AND ended_at < '2026-06-01'
        ) / COUNT(*),
        1
    ) AS churn_rate

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND started_at < '2026-05-01'
  AND (
      ended_at IS NULL
      OR ended_at >= '2026-05-01'
  );
```

## Calculation

Paid monthly subscriptions active at the beginning of May:

**7,444**

Paid monthly subscriptions whose access ended during May:

**276**

```text
276 / 7,444 × 100
= 3.71%
```

Rounded to one decimal place:

### Answer: **3.7%**

---

# 3. Which signup-month cohort accounts for the most churned subscribers in June 2026?

Instead of looking only at month-over-month churn, June churners were split by their **signup month**.

The signup cohort is derived from:

```text
subscriptions.started_at
```

For example:

```text
2026-03-14 → March 2026 cohort
2026-03-25 → March 2026 cohort
2026-04-05 → April 2026 cohort
```

## SQL

```sql
SELECT
    DATE_FORMAT(started_at, '%Y-%m') AS signup_month,
    COUNT(*) AS june_churned

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'

GROUP BY DATE_FORMAT(started_at, '%Y-%m')

ORDER BY june_churned DESC;
```

## Result

The largest June churn cohort was:

| Signup cohort | June churned |
|---|---:|
| **2026-03** | **572** |

### Answer: **March 2026 (`2026-03`)**

---

# 4. For the March 2026 cohort, how many subscribers had their access end in June 2026?

After identifying March 2026 as the largest June churn cohort, I counted subscriptions that satisfied all of these conditions:

- Paid subscription
- Monthly plan
- Started during March 2026
- Access ended during June 2026

## SQL

```sql
SELECT
    COUNT(*) AS march_cohort_june_ends

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'

  AND started_at >= '2026-03-01'
  AND started_at < '2026-04-01'

  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01';
```

## Result

```text
March 2026 cohort June access ends = 572
```

### Answer: **572 subscribers**

---

# 5. What was June's churn rate excluding the March 2026 cohort?

The March 2026 cohort was removed from **both the numerator and denominator**, as required.

This is important because removing the cohort only from the numerator would produce an incorrect churn rate.

---

## Step 1 — June churn numerator

Total paid monthly subscriptions whose access ended in June:

**914**

March 2026 cohort whose access ended in June:

**572**

Therefore:

```text
914 - 572 = 342
```

June churn excluding March cohort:

**342**

---

## Step 2 — June active denominator

Paid monthly subscribers active at the beginning of June:

**8,183**

March 2026 cohort subscribers active at the beginning of June:

**1,774**

Therefore:

```text
8,183 - 1,774 = 6,409
```

Active subscribers excluding March cohort:

**6,409**

---

## Step 3 — Recalculate churn

```text
342 / 6,409 × 100
= 5.34%
```

Rounded to one decimal place:

### Answer: **5.3%**

## SQL

```sql
SELECT
    ROUND(
        100 *
        SUM(
            ended_at >= '2026-06-01'
            AND ended_at < '2026-07-01'
        ) / COUNT(*),
        1
    ) AS churn_excluding_march

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'

  -- Active at the beginning of June
  AND started_at < '2026-06-01'
  AND (
      ended_at IS NULL
      OR ended_at >= '2026-06-01'
  )

  -- Exclude March 2026 signup cohort
  AND NOT (
      started_at >= '2026-03-01'
      AND started_at < '2026-04-01'
  );
```

---

# Final Verified Answers

| # | Question | Verified Answer |
|---|---|---:|
| 1 | June 2026 monthly churn | **11.2%** |
| 2 | May 2026 monthly churn | **3.7%** |
| 3 | Signup-month cohort with most June churn | **2026-03** |
| 4 | March 2026 cohort June access ends | **572** |
| 5 | June churn excluding March cohort | **5.3%** |

---

# What These Results Tell Us

June monthly churn increased from:

```text
May 2026     3.7%
      ↓
June 2026   11.2%
```

However, the increase was not evenly distributed across the subscriber base.

The March 2026 signup cohort contributed:

```text
572 / 914 × 100
= 62.6%
```

of all June churned subscriptions.

When the March cohort is removed from both the numerator and denominator:

```text
June churn
11.2%
  ↓
5.3%
```

This shows that the June spike was heavily concentrated in the March signup cohort.

---

# Analytical Interpretation

The March cohort is important because March coincided with the acquisition campaign.

The campaign created an unusually large group of subscribers, and many of those subscribers subsequently reached their access-end dates in June.

Therefore, the June churn spike should not automatically be interpreted as a broad-based deterioration in customer retention.

The analysis separates:

1. The overall June churn increase.
2. The March cohort effect.
3. The potential price effect.

---

# Price Increase Interpretation

The monthly plan price increased from:

```text
₹399 → ₹449
```

on June 1.

However, the June churn population does not provide a clean test of the price increase.

Customers whose access ended during June largely started their subscriptions before the June 1 price change.

Therefore:

> **The June churn data does not prove that the ₹449 price caused the June churn spike.**

At the same time, the analysis does not prove that the price increase has no effect.

The correct next step is to measure renewal and churn among customers who were actually exposed to the ₹449 price.

---

# Business Recommendation

### Keep the ₹449 price for now.

Do **not** roll back the price on September 1 based on the June churn spike alone.

The evidence shows:

- Verified June churn = **11.2%**
- May churn = **3.7%**
- March cohort = **572 of 914 June churns**
- June churn excluding March = **5.3%**

The June spike is therefore heavily concentrated in the March cohort.

The price increase should be evaluated using a future cohort whose renewal/payment actually occurred at ₹449.

A rollback should only be considered if the post-price cohort shows a persistent incremental churn increase large enough to outweigh the additional ₹50 monthly revenue per retained subscriber.
