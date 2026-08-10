-- March acquisition
SELECT
    acquisition_channel,
    COUNT(*) AS users,
    ROUND(
        100 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS share_pct
FROM users
WHERE signup_date >= '2026-03-01'
  AND signup_date < '2026-04-01'
GROUP BY acquisition_channel
ORDER BY users DESC;

-- June churn by price/promotion
SELECT
    price_inr,
    promo_code,
    COUNT(*) AS june_ends
FROM subscriptions_clean
WHERE is_trial = 0
  AND plan = 'monthly'
  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'
GROUP BY
    price_inr,
    promo_code
ORDER BY june_ends DESC;

-- Specifically test ₹449
SELECT COUNT(*) AS june_ends_at_449
FROM subscriptions_clean
WHERE is_trial = 0
  AND plan = 'monthly'
  AND price_inr = 449
  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01';
