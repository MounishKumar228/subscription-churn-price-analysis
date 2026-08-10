SELECT
    DATE_FORMAT(started_at, '%Y-%m') AS cohort_month,

    COUNT(*) AS active_entering_june,

    SUM(
        ended_at >= '2026-06-01'
        AND ended_at < '2026-07-01'
    ) AS june_ends,

    ROUND(
        100 * SUM(
            ended_at >= '2026-06-01'
            AND ended_at < '2026-07-01'
        ) / COUNT(*),
        2
    ) AS june_churn_pct

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND started_at < '2026-06-01'
  AND (
      ended_at IS NULL
      OR ended_at >= '2026-06-01'
  )

GROUP BY DATE_FORMAT(started_at, '%Y-%m')

ORDER BY cohort_month;
