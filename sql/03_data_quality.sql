USE subscriptionanalysis;

-- Total records
SELECT COUNT(*) AS total_subscription_rows
FROM subscriptions;

-- Unique subscriptions
SELECT COUNT(DISTINCT subscription_id) AS unique_subscription_ids
FROM subscriptions;

-- Duplicate subscription IDs
SELECT
    subscription_id,
    COUNT(*) AS record_count
FROM subscriptions
GROUP BY subscription_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

-- verify exact duplicates
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
HAVING COUNT(*) > 1;

-- Create a clean analytical dataset

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

SELECT COUNT(*) 
FROM subscriptions_clean;
