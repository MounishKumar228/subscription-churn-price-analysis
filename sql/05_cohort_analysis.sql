USE subscriptionanalysis;

-- ============================================================
-- 05_COHORT_ANALYSIS.SQL
-- June 2026 Churn by Signup Cohort
-- ============================================================

/*
PURPOSE

Month-over-month churn tells us that June was worse than May,
but it does not tell us WHICH customers drove the increase.

Therefore, June churners are segmented by the month in which
their subscription started.

SIGNUP COHORT

signup_month = month of started_at

OFFICIAL POPULATION

    is_trial = 0
    plan = 'monthly'

JUNE CHURN

    ended_at >= '2026-06-01'
    AND ended_at < '2026-07-01'
*/


-- ============================================================
-- 1. JUNE CHURN BY SIGNUP-MONTH COHORT
-- ============================================================

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


-- ============================================================
-- 2. JUNE CHURN BY COHORT WITH SHARE OF TOTAL JUNE CHURN
-- ============================================================

SELECT
    DATE_FORMAT(started_at, '%Y-%m') AS signup_month,

    COUNT(*) AS june_churned,

    ROUND(
        100 * COUNT(*) /
        (
            SELECT COUNT(*)
            FROM subscriptions_clean
            WHERE is_trial = 0
              AND plan = 'monthly'
              AND ended_at >= '2026-06-01'
              AND ended_at < '2026-07-01'
        ),
        1
    ) AS share_of_june_churn_pct

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'

GROUP BY DATE_FORMAT(started_at, '%Y-%m')

ORDER BY june_churned DESC;


-- ============================================================
-- 3. IDENTIFY THE LARGEST JUNE CHURN COHORT
-- ============================================================

SELECT
    DATE_FORMAT(started_at, '%Y-%m') AS signup_month,
    COUNT(*) AS june_churned

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'

GROUP BY DATE_FORMAT(started_at, '%Y-%m')

ORDER BY june_churned DESC

LIMIT 1;


-- ============================================================
-- 4. COUNT MARCH 2026 COHORT SUBSCRIPTIONS ENDING IN JUNE
-- ============================================================

SELECT
    COUNT(*) AS march_cohort_june_churn

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'

  AND started_at >= '2026-03-01'
  AND started_at < '2026-04-01'

  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01';


-- ============================================================
-- 5. MARCH COHORT SHARE OF JUNE CHURN
-- ============================================================

SELECT
    COUNT(*) AS march_cohort_june_churn,

    (
        SELECT COUNT(*)
        FROM subscriptions_clean
        WHERE is_trial = 0
          AND plan = 'monthly'
          AND ended_at >= '2026-06-01'
          AND ended_at < '2026-07-01'
    ) AS total_june_churn,

    ROUND(
        100 * COUNT(*) /
        (
            SELECT COUNT(*)
            FROM subscriptions_clean
            WHERE is_trial = 0
              AND plan = 'monthly'
              AND ended_at >= '2026-06-01'
              AND ended_at < '2026-07-01'
        ),
        1
    ) AS march_share_of_june_churn_pct

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND started_at >= '2026-03-01'
  AND started_at < '2026-04-01'
  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01';


-- ============================================================
-- 6. HOW MANY MARCH COHORT SUBSCRIBERS WERE ACTIVE
--    AT THE FIRST INSTANT OF JUNE?
-- ============================================================

SELECT
    COUNT(*) AS march_cohort_active_at_start_of_june

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'

  AND started_at >= '2026-03-01'
  AND started_at < '2026-04-01'

  AND started_at < '2026-06-01'

  AND (
      ended_at IS NULL
      OR ended_at >= '2026-06-01'
  );


-- ============================================================
-- 7. JUNE CHURN EXCLUDING MARCH COHORT
-- ============================================================

SELECT
    COUNT(*) AS active_excluding_march,

    SUM(
        ended_at >= '2026-06-01'
        AND ended_at < '2026-07-01'
    ) AS june_churn_excluding_march,

    ROUND(
        100 *
        SUM(
            ended_at >= '2026-06-01'
            AND ended_at < '2026-07-01'
        )
        / COUNT(*),
        1
    ) AS churn_excluding_march_pct

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'

  -- Active at the first instant of June
  AND started_at < '2026-06-01'
  AND (
      ended_at IS NULL
      OR ended_at >= '2026-06-01'
  )

  -- Remove March 2026 signup cohort
  AND NOT (
      started_at >= '2026-03-01'
      AND started_at < '2026-04-01'
  );


-- ============================================================
-- 8. COMPARE OVERALL JUNE CHURN WITH CHURN EXCLUDING MARCH
-- ============================================================

SELECT
    'All cohorts' AS population,

    COUNT(*) AS active_at_start,

    SUM(
        ended_at >= '2026-06-01'
        AND ended_at < '2026-07-01'
    ) AS june_churned,

    ROUND(
        100 *
        SUM(
            ended_at >= '2026-06-01'
            AND ended_at < '2026-07-01'
        )
        / COUNT(*),
        1
    ) AS churn_rate

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND started_at < '2026-06-01'
  AND (
      ended_at IS NULL
      OR ended_at >= '2026-06-01'
  )

UNION ALL

SELECT
    'Excluding March 2026 cohort' AS population,

    COUNT(*) AS active_at_start,

    SUM(
        ended_at >= '2026-06-01'
        AND ended_at < '2026-07-01'
    ) AS june_churned,

    ROUND(
        100 *
        SUM(
            ended_at >= '2026-06-01'
            AND ended_at < '2026-07-01'
        )
        / COUNT(*),
        1
    ) AS churn_rate

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


-- ============================================================
-- 9. MARCH COHORT VS ALL OTHER COHORTS
-- ============================================================

SELECT
    CASE
        WHEN started_at >= '2026-03-01'
         AND started_at < '2026-04-01'
        THEN 'March 2026 cohort'
        ELSE 'All other cohorts'
    END AS cohort_group,

    COUNT(*) AS june_churned

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'

GROUP BY
    CASE
        WHEN started_at >= '2026-03-01'
         AND started_at < '2026-04-01'
        THEN 'March 2026 cohort'
        ELSE 'All other cohorts'
    END

ORDER BY june_churned DESC;


-- ============================================================
-- 10. CHECK JUNE CHURN BY MONTHS SINCE SIGNUP
-- ============================================================

/*
This helps understand the timing of the March cohort.

For each June churner, calculate the approximate number of
months between subscription start and access ending.
*/

SELECT
    TIMESTAMPDIFF(
        MONTH,
        started_at,
        ended_at
    ) AS months_since_signup,

    COUNT(*) AS june_churned

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'

GROUP BY
    TIMESTAMPDIFF(
        MONTH,
        started_at,
        ended_at
    )

ORDER BY months_since_signup;


-- ============================================================
-- 11. FINAL COHORT FINDING
-- ============================================================

/*
FINAL FINDING

The March 2026 signup cohort is the largest contributor to
June 2026 churn.

Verified results:

    Total June churn = 914

    March cohort June churn = 572

    March share of June churn = 62.6%

    June churn including March = 11.2%

    June churn excluding March = 5.3%

The March cohort therefore explains a substantial portion of
the June spike.

The next analysis investigates why March was unusually large,
including the acquisition campaign and promotional activity.

This is important because cohort concentration should be
separated from the potential effect of the June price change.
*/
