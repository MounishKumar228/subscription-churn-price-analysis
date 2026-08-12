# Five Verified Answers — Subscription Churn Analysis

## 1. What was the monthly churn rate in June 2026?

### Definition

The assessment defines churn as:

**Churn rate = subscriptions whose access ended during the month ÷ subscriptions active at the first instant of that month**

Population:
- Paid monthly subscribers only
- `is_trial = 0`
- `plan = 'monthly'`
- `ended_at` is used because it represents when customer access actually stopped.

### SQL

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

### Calculation

Active at the start of June = **8,183**

Subscriptions whose access ended during June = **914**

**June churn = 914 / 8,183 × 100 = 11.17%**

Rounded to one decimal place:

### Answer: **11.2%**

---

## 2. What was the monthly churn rate in May 2026?

The same definition and population were used, changing only the analysis month from June to May.

### SQL

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

### Calculation

Active at the start of May = **7,444**

Subscriptions whose access ended during May = **276**

**May churn = 276 / 7,444 × 100 = 3.71%**

Rounded to one decimal place:

### Answer: **3.7%**

---

## 3. Which signup-month cohort accounts for the most churned subscribers in June 2026?

The June churners were grouped according to the month in which their subscription started.

The signup cohort is derived from:

`subscriptions.started_at`

For example:

- `2026-03-14` → March 2026 cohort
- `2026-03-25` → March 2026 cohort
- `2026-04-05` → April 2026 cohort

### SQL

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

### Result

The largest June churn cohort was:

**2026-03 → 572 subscriptions**

### Answer: **March 2026 (`2026-03`)**

---

## 4. For the March 2026 cohort, how many subscribers had their access end in June 2026?

After identifying March 2026 as the cohort with the most June churn, I counted subscriptions satisfying all of the following:

- Paid subscription
- Monthly plan
- Started during March 2026
- Access ended during June 2026

### SQL

SELECT
    COUNT(*) AS march_cohort_june_ends
FROM subscriptions_clean
WHERE is_trial = 0
  AND plan = 'monthly'
  AND started_at >= '2026-03-01'
  AND started_at < '2026-04-01'
  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01';

### Result

March 2026 cohort subscriptions whose access ended in June:

### Answer: **572 subscribers**

---

## 5. What was June's churn rate excluding the March 2026 cohort?

The March 2026 cohort was removed from **both the numerator and denominator**.

### Step 1 — Remove March cohort from numerator

Total June churn:

**914**

March cohort June churn:

**572**

Therefore:

**914 - 572 = 342**

June churn excluding March cohort = **342**

### Step 2 — Remove March cohort from denominator

Paid monthly subscribers active at the beginning of June:

**8,183**

March cohort subscribers active at the beginning of June:

**1,774**

Therefore:

**8,183 - 1,774 = 6,409**

Active subscribers excluding March cohort = **6,409**

### Step 3 — Recalculate churn

**342 / 6,409 × 100 = 5.34%**

Rounded to one decimal place:

### Answer: **5.3%**

### SQL

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
  AND started_at < '2026-06-01'
  AND (
      ended_at IS NULL
      OR ended_at >= '2026-06-01'
  )
  AND NOT (
      started_at >= '2026-03-01'
      AND started_at < '2026-04-01'
  );

---

# Final Verified Answers

| # | Question | Answer |
|---|---|---:|
| 1 | June 2026 monthly churn | **11.2%** |
| 2 | May 2026 monthly churn | **3.7%** |
| 3 | Signup-month cohort with most June churn | **2026-03** |
| 4 | March 2026 cohort June access ends | **572** |
| 5 | June churn excluding March 2026 cohort | **5.3%** |

---

# Key Finding

June monthly churn increased from **3.7% in May to 11.2% in June**.

However, **572 of the 914 June churned subscriptions came from the March 2026 signup cohort**.

When the March 2026 cohort is removed from both the numerator and denominator, June churn falls to **5.3%**.

This shows that the June spike was heavily concentrated in the March signup cohort rather than being a uniform increase across the entire monthly subscriber base.
