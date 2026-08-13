USE subscriptionanalysis;

-- ============================================================
-- 03_DATA_QUALITY.SQL
-- Subscription data quality and duplicate investigation
-- ============================================================

/*
PURPOSE

Before calculating churn, the raw subscription data is checked
for duplicate records and subscription structure.

IMPORTANT:

A repeated subscription_id does NOT automatically mean that
the record is invalid.

The business description states that:

- A 14-day free trial creates its own subscription row.
- A trial that converts also creates a subscription row.

Therefore, multiple rows can legitimately be associated with
the same user or subscription lifecycle.

The goal is to identify EXACT duplicate records rather than
blindly removing every repeated subscription_id.
*/


-- ============================================================
-- 1. Check total number of raw subscription rows
-- ============================================================

SELECT
    COUNT(*) AS total_subscription_rows
FROM subscriptions;


-- ============================================================
-- 2. Check number of unique subscription IDs
-- ============================================================

SELECT
    COUNT(DISTINCT subscription_id) AS unique_subscription_ids
FROM subscriptions;


-- ============================================================
-- 3. Find subscription IDs that occur more than once
-- ============================================================

SELECT
    subscription_id,
    COUNT(*) AS record_count
FROM subscriptions
GROUP BY subscription_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


-- ============================================================
-- 4. Investigate whether repeated subscription IDs represent
--    different subscription records
-- ============================================================

SELECT
    subscription_id,
    user_id,
    plan,
    is_trial,
    started_at,
    price_inr,
    promo_code,
    cancelled_at,
    ended_at,
    status
FROM subscriptions
WHERE subscription_id IN (
    SELECT subscription_id
    FROM subscriptions
    GROUP BY subscription_id
    HAVING COUNT(*) > 1
)
ORDER BY subscription_id, started_at;


-- ============================================================
-- 5. Check for EXACT duplicate rows
--
-- Two rows are treated as exact duplicates only when all
-- business columns contain the same values.
-- ============================================================

SELECT
    subscription_id,
    user_id,
    plan,
    is_trial,
    started_at,
    price_inr,
    promo_code,
    cancelled_at,
    ended_at,
    status,
    COUNT(*) AS duplicate_count
FROM subscriptions
GROUP BY
    subscription_id,
    user_id,
    plan,
    is_trial,
    started_at,
    price_inr,
    promo_code,
    cancelled_at,
    ended_at,
    status
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ============================================================
-- 6. Check duplicate rows associated with the same user
-- ============================================================

SELECT
    user_id,
    COUNT(*) AS subscription_rows
FROM subscriptions
GROUP BY user_id
HAVING COUNT(*) > 1
ORDER BY subscription_rows DESC;


-- ============================================================
-- 7. Check trial vs paid rows for users with multiple
--    subscription records
-- ============================================================

SELECT
    user_id,
    SUM(is_trial = 1) AS trial_rows,
    SUM(is_trial = 0) AS paid_rows,
    COUNT(*) AS total_rows
FROM subscriptions
GROUP BY user_id
HAVING COUNT(*) > 1
ORDER BY total_rows DESC;


-- ============================================================
-- 8. Create a clean analytical table
--
-- Exact duplicate rows are removed.
--
-- DISTINCT is used across the complete record rather than
-- using DISTINCT subscription_id.
--
-- This is important because a user can legitimately have
-- multiple subscription rows.
-- ============================================================

DROP TABLE IF EXISTS subscriptions_clean;

CREATE TABLE subscriptions_clean AS
SELECT DISTINCT
    subscription_id,
    user_id,
    LOWER(plan) AS plan,
    is_trial,
    started_at,
    price_inr,
    promo_code,
    cancelled_at,
    ended_at,
    status
FROM subscriptions;


-- ============================================================
-- 9. Validate the cleaned table
-- ============================================================

SELECT
    COUNT(*) AS clean_rows,
    COUNT(DISTINCT subscription_id) AS clean_unique_subscription_ids,
    COUNT(DISTINCT user_id) AS clean_unique_users
FROM subscriptions_clean;


-- ============================================================
-- 10. Confirm that exact duplicate records remain removed
-- ============================================================

SELECT
    subscription_id,
    user_id,
    plan,
    is_trial,
    started_at,
    price_inr,
    promo_code,
    cancelled_at,
    ended_at,
    status,
    COUNT(*) AS duplicate_count
FROM subscriptions_clean
GROUP BY
    subscription_id,
    user_id,
    plan,
    is_trial,
    started_at,
    price_inr,
    promo_code,
    cancelled_at,
    ended_at,
    status
HAVING COUNT(*) > 1;


-- ============================================================
-- 11. Check trial and paid subscription populations
-- ============================================================

SELECT
    is_trial,
    COUNT(*) AS subscription_rows
FROM subscriptions_clean
GROUP BY is_trial
ORDER BY is_trial;


-- ============================================================
-- 12. Check monthly vs non-monthly subscription population
-- ============================================================

SELECT
    plan,
    COUNT(*) AS subscription_rows
FROM subscriptions_clean
GROUP BY plan
ORDER BY subscription_rows DESC;


-- ============================================================
-- DATA QUALITY CONCLUSION
-- ============================================================

/*
CONCLUSION

The raw subscription data can contain multiple rows associated
with the same customer/subscription lifecycle.

This is expected because the 14-day trial creates its own
subscription row and a trial that converts also creates a
subscription row.

Therefore:

1. Repeated user_id values are not automatically duplicates.
2. Repeated subscription_id values must be investigated rather
   than blindly removed.
3. Only exact duplicate rows are removed for the analytical
   dataset.
4. The cleaned table is subscriptions_clean.
5. Churn calculations are performed using subscriptions_clean.
*/
