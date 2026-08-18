USE subscriptionanalysis;

-- ============================================================
-- 07 LAUNCH60 MECHANISM ANALYSIS
-- Why did the March 2026 cohort drive June churn?
-- ============================================================


-- ============================================================
-- 1. PROMO CODES USED BY THE MARCH COHORT
-- ============================================================

SELECT
    COALESCE(promo_code, 'NO PROMO') AS promo_code,
    COUNT(*) AS subscription_rows

FROM subscriptions_clean

WHERE started_at >= '2026-03-01'
  AND started_at < '2026-04-01'

GROUP BY COALESCE(promo_code, 'NO PROMO')

ORDER BY subscription_rows DESC;


-- ============================================================
-- 2. LAUNCH60 SUBSCRIPTIONS BY START MONTH
-- ============================================================

SELECT
    DATE_FORMAT(started_at, '%Y-%m') AS start_month,
    COUNT(*) AS launch60_subscriptions

FROM subscriptions_clean

WHERE promo_code = 'LAUNCH60'

GROUP BY DATE_FORMAT(started_at, '%Y-%m')

ORDER BY start_month;


-- ============================================================
-- 3. MARCH LAUNCH60 SUBSCRIPTIONS
-- ============================================================

SELECT
    COUNT(*) AS march_launch60_subscriptions

FROM subscriptions_clean

WHERE started_at >= '2026-03-01'
  AND started_at < '2026-04-01'
  AND promo_code = 'LAUNCH60';


-- ============================================================
-- 4. MARCH LAUNCH60 SUBSCRIPTIONS THAT ENDED IN JUNE
-- ============================================================

SELECT
    COUNT(*) AS launch60_june_ends

FROM subscriptions_clean

WHERE started_at >= '2026-03-01'
  AND started_at < '2026-04-01'

  AND promo_code = 'LAUNCH60'

  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01';


-- ============================================================
-- 5. JUNE CHURN BY PROMO CODE
-- ============================================================

SELECT
    COALESCE(promo_code, 'NO PROMO') AS promo_code,
    COUNT(*) AS june_churned

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'

  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'

GROUP BY COALESCE(promo_code, 'NO PROMO')

ORDER BY june_churned DESC;


-- ============================================================
-- 6. MARCH COHORT JUNE CHURN BY PROMO CODE
-- ============================================================

SELECT
    COALESCE(promo_code, 'NO PROMO') AS promo_code,
    COUNT(*) AS june_churned

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'

  AND started_at >= '2026-03-01'
  AND started_at < '2026-04-01'

  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'

GROUP BY COALESCE(promo_code, 'NO PROMO')

ORDER BY june_churned DESC;


-- ============================================================
-- 7. MARCH LAUNCH60 COHORT:
-- START DATE, PRICE AND END DATE
-- ============================================================

SELECT
    price_inr,
    COUNT(*) AS subscriptions,
    MIN(started_at) AS first_start,
    MAX(started_at) AS last_start,
    MIN(ended_at) AS first_end,
    MAX(ended_at) AS last_end

FROM subscriptions_clean

WHERE started_at >= '2026-03-01'
  AND started_at < '2026-04-01'
  AND promo_code = 'LAUNCH60'

GROUP BY price_inr

ORDER BY price_inr;


-- ============================================================
-- 8. MARCH LAUNCH60 SUBSCRIPTIONS THAT ENDED IN JUNE
-- BY PRICE
-- ============================================================

SELECT
    price_inr,
    COUNT(*) AS june_ends

FROM subscriptions_clean

WHERE started_at >= '2026-03-01'
  AND started_at < '2026-04-01'

  AND promo_code = 'LAUNCH60'

  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'

GROUP BY price_inr

ORDER BY june_ends DESC;


-- ============================================================
-- 9. TIME FROM START TO ACCESS END
-- ============================================================

SELECT
    TIMESTAMPDIFF(
        DAY,
        started_at,
        ended_at
    ) AS days_from_start_to_end,

    COUNT(*) AS subscriptions

FROM subscriptions_clean

WHERE started_at >= '2026-03-01'
  AND started_at < '2026-04-01'

  AND promo_code = 'LAUNCH60'

  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'

GROUP BY
    TIMESTAMPDIFF(
        DAY,
        started_at,
        ended_at
    )

ORDER BY days_from_start_to_end;


-- ============================================================
-- 10. MARCH LAUNCH60 JUNE CHURN:
-- CANCELLED VS ACCESS END
-- ============================================================

SELECT
    CASE
        WHEN cancelled_at IS NOT NULL
            THEN 'Cancelled in app'
        ELSE 'No cancellation timestamp'
    END AS cancellation_status,

    COUNT(*) AS subscriptions

FROM subscriptions_clean

WHERE started_at >= '2026-03-01'
  AND started_at < '2026-04-01'

  AND promo_code = 'LAUNCH60'

  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'

GROUP BY
    CASE
        WHEN cancelled_at IS NOT NULL
            THEN 'Cancelled in app'
        ELSE 'No cancellation timestamp'
    END;


-- ============================================================
-- 11. MARCH LAUNCH60 JUNE ENDS BY END DATE
-- ============================================================

SELECT
    DATE(ended_at) AS access_end_date,
    COUNT(*) AS ended_subscriptions

FROM subscriptions_clean

WHERE started_at >= '2026-03-01'
  AND started_at < '2026-04-01'

  AND promo_code = 'LAUNCH60'

  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'

GROUP BY DATE(ended_at)

ORDER BY access_end_date;


-- ============================================================
-- 12. MECHANISM CHECK
-- ============================================================

/*
The purpose of this analysis is to establish whether the
March cohort's June access endings align with the end of the
LAUNCH60 promotional period and the first full-price billing
event.

The expected business mechanism is:

    March acquisition
          ↓
    LAUNCH60 promotion
          ↓
    Promotional period ends
          ↓
    First full-price bill
          ↓
    Customer cancellation/churn
          ↓
    Access ends in June

The price increase on June 1 is a separate event.

Therefore, the June spike should not automatically be attributed
to the ₹399 → ₹449 change.
*/
