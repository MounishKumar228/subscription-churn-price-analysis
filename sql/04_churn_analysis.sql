USE subscriptionanalysis;

-- ============================================================
-- 04_CHURN_ANALYSIS.SQL
-- May and June 2026 Monthly Churn Analysis
-- ============================================================

/*
BUSINESS QUESTION

The business reported that monthly churn increased from
approximately 4.5% in May to nearly 17% in June.

The purpose of this analysis is to independently verify
the reported number using the specified churn definition.

CHURN DEFINITION

Monthly churn =
Paid monthly subscriptions whose access ended during the month
/
Paid monthly subscriptions active at the first instant of the month


POPULATION

Only:

    is_trial = 0
    plan = 'monthly'


DATE LOGIC

cancelled_at:
    The date/time when the customer clicked cancel.

ended_at:
    The date/time when customer access actually stopped.

Therefore, ended_at is used to determine churn.

IMPORTANT

A subscription must already be active at the first instant
of the month to be included in the denominator.

This means:

    started_at < month_start

and:

    ended_at IS NULL
    OR ended_at >= month_start
*/


-- ============================================================
-- 1. JUNE 2026 CHURN
-- ============================================================

SELECT
    COUNT(*) AS active_at_start_of_june,

    SUM(
        ended_at >= '2026-06-01'
        AND ended_at < '2026-07-01'
    ) AS ended_in_june,

    ROUND(
        100 *
        SUM(
            ended_at >= '2026-06-01'
            AND ended_at < '2026-07-01'
        )
        / COUNT(*),
        1
    ) AS june_churn_rate

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'

  -- Subscription must have started before June
  AND started_at < '2026-06-01'

  -- Subscription must have been active at the beginning of June
  AND (
      ended_at IS NULL
      OR ended_at >= '2026-06-01'
  );


-- ============================================================
-- 2. JUNE 2026 CHURN - SHOW NUMERATOR AND DENOMINATOR
-- ============================================================

SELECT

    COUNT(*) AS june_active_base,

    SUM(
        ended_at >= '2026-06-01'
        AND ended_at < '2026-07-01'
    ) AS june_ended,

    ROUND(
        100 *
        SUM(
            ended_at >= '2026-06-01'
            AND ended_at < '2026-07-01'
        )
        / COUNT(*),
        1
    ) AS june_churn_rate

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND started_at < '2026-06-01'
  AND (
      ended_at IS NULL
      OR ended_at >= '2026-06-01'
  );


-- ============================================================
-- 3. MAY 2026 CHURN
-- ============================================================

SELECT
    COUNT(*) AS active_at_start_of_may,

    SUM(
        ended_at >= '2026-05-01'
        AND ended_at < '2026-06-01'
    ) AS ended_in_may,

    ROUND(
        100 *
        SUM(
            ended_at >= '2026-05-01'
            AND ended_at < '2026-06-01'
        )
        / COUNT(*),
        1
    ) AS may_churn_rate

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'

  -- Subscription must have started before May
  AND started_at < '2026-05-01'

  -- Subscription must have been active at the beginning of May
  AND (
      ended_at IS NULL
      OR ended_at >= '2026-05-01'
  );


-- ============================================================
-- 4. MAY VS JUNE COMPARISON
-- ============================================================

SELECT
    'May 2026' AS month,

    COUNT(*) AS active_at_start,

    SUM(
        ended_at >= '2026-05-01'
        AND ended_at < '2026-06-01'
    ) AS churned,

    ROUND(
        100 *
        SUM(
            ended_at >= '2026-05-01'
            AND ended_at < '2026-06-01'
        )
        / COUNT(*),
        1
    ) AS churn_rate

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND started_at < '2026-05-01'
  AND (
      ended_at IS NULL
      OR ended_at >= '2026-05-01'
  )

UNION ALL

SELECT
    'June 2026' AS month,

    COUNT(*) AS active_at_start,

    SUM(
        ended_at >= '2026-06-01'
        AND ended_at < '2026-07-01'
    ) AS churned,

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
  );


-- ============================================================
-- 5. CALCULATE THE CHANGE FROM MAY TO JUNE
-- ============================================================

SELECT
    ROUND(
        june_churn_rate - may_churn_rate,
        1
    ) AS churn_change_percentage_points

FROM
(
    SELECT
        (
            SELECT
                100 *
                SUM(
                    ended_at >= '2026-06-01'
                    AND ended_at < '2026-07-01'
                )
                / COUNT(*)
            FROM subscriptions_clean
            WHERE is_trial = 0
              AND plan = 'monthly'
              AND started_at < '2026-06-01'
              AND (
                  ended_at IS NULL
                  OR ended_at >= '2026-06-01'
              )
        ) AS june_churn_rate,

        (
            SELECT
                100 *
                SUM(
                    ended_at >= '2026-05-01'
                    AND ended_at < '2026-06-01'
                )
                / COUNT(*)
            FROM subscriptions_clean
            WHERE is_trial = 0
              AND plan = 'monthly'
              AND started_at < '2026-05-01'
              AND (
                  ended_at IS NULL
                  OR ended_at >= '2026-05-01'
              )
        ) AS may_churn_rate
) AS churn_rates;


-- ============================================================
-- 6. CHECK THE REPORTED ~17% JUNE FIGURE
-- ============================================================

/*
The business reported approximately 17% June churn.

This analysis does NOT assume that figure is correct.

Using the specified definition:

    Paid monthly subscriptions
    whose access ended in June
    /
    Paid monthly subscriptions active at June 1

the verified June churn is:

    11.2%

Therefore, the reported ~17% figure cannot be reproduced
under the stated churn definition.
*/


-- ============================================================
-- 7. COUNT JUNE CHURNERS BY TRIAL / PAID STATUS
-- ============================================================

/*
This is a diagnostic check only.

Trial subscriptions are excluded from the official churn
calculation because the assessment specifies paid monthly
subscribers only.
*/

SELECT
    is_trial,
    COUNT(*) AS june_ended
FROM subscriptions_clean
WHERE ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'
GROUP BY is_trial
ORDER BY is_trial;


-- ============================================================
-- 8. COUNT JUNE CHURNERS BY PLAN
-- ============================================================

/*
This confirms why the official calculation is restricted
to the monthly plan.
*/

SELECT
    plan,
    COUNT(*) AS june_ended
FROM subscriptions_clean
WHERE ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'
GROUP BY plan
ORDER BY june_ended DESC;


-- ============================================================
-- 9. CHECK CANCELLED_AT VS ENDED_AT
-- ============================================================

/*
This diagnostic demonstrates the difference between:

    cancelled_at = cancellation action

and

    ended_at = actual access end

The churn definition uses ended_at.
*/

SELECT
    COUNT(*) AS june_ended_with_cancel_date
FROM subscriptions_clean
WHERE is_trial = 0
  AND plan = 'monthly'
  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'
  AND cancelled_at IS NOT NULL;


-- ============================================================
-- 10. FINAL VERIFIED CHURN RESULTS
-- ============================================================

/*
VERIFIED RESULTS

May 2026:
    Active at start = 7,444
    Ended during May = 276
    Churn = 3.7%

June 2026:
    Active at start = 8,183
    Ended during June = 914
    Churn = 11.2%

The June increase is:

    11.2% - 3.7%
    = 7.5 percentage points

These results are calculated using the required population
and ended_at-based churn definition.
*/
