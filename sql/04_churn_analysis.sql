USE subscriptionanalysis;

WITH monthly AS (
    SELECT *
    FROM subscriptions_clean
    WHERE is_trial = 0
      AND plan = 'monthly'
),

may AS (
    SELECT
        COUNT(*) AS active_at_start,
        SUM(
            ended_at >= '2026-05-01'
            AND ended_at < '2026-06-01'
        ) AS ended
    FROM monthly
    WHERE started_at < '2026-05-01'
      AND (
          ended_at IS NULL
          OR ended_at >= '2026-05-01'
      )
),

june AS (
    SELECT
        COUNT(*) AS active_at_start,
        SUM(
            ended_at >= '2026-06-01'
            AND ended_at < '2026-07-01'
        ) AS ended
    FROM monthly
    WHERE started_at < '2026-06-01'
      AND (
          ended_at IS NULL
          OR ended_at >= '2026-06-01'
      )
)

SELECT
    'May 2026' AS month,
    active_at_start,
    ended,
    ROUND(100 * ended / active_at_start, 2) AS churn_pct
FROM may

UNION ALL

SELECT
    'June 2026',
    active_at_start,
    ended,
    ROUND(100 * ended / active_at_start, 2)
FROM june;
