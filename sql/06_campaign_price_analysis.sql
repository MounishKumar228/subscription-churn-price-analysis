USE subscriptionanalysis;

-- ============================================================
-- 06_CAMPAIGN_PRICE_ANALYSIS.SQL
-- March Acquisition Campaign & June Price Analysis
-- ============================================================

/*
PURPOSE

The June churn increase should not automatically be attributed
to the ₹399 -> ₹449 price increase.

The business ran an acquisition campaign in March, so this
analysis investigates:

1. March signup volume
2. March acquisition channels
3. Promotion usage
4. June churn by starting price
5. Whether June churn provides a valid test of the new ₹449 price

IMPORTANT:

A correlation between a price and churn does not by itself
establish causation.

The price changed on June 1, while June churn is based on
subscriptions whose access actually ended during June.
*/


-- ============================================================
-- 1. SIGNUPS BY MONTH
-- ============================================================

/*
Purpose:
Check whether March was unusually large compared with
surrounding signup months.
*/

SELECT
    DATE_FORMAT(signup_date, '%Y-%m') AS signup_month,
    COUNT(*) AS signups

FROM users

GROUP BY DATE_FORMAT(signup_date, '%Y-%m')

ORDER BY signup_month;


-- ============================================================
-- 2. MARCH SIGNUPS BY ACQUISITION CHANNEL
-- ============================================================

/*
Purpose:
Understand which acquisition channels contributed to the
March signup cohort.
*/

SELECT
    acquisition_channel,
    COUNT(*) AS signups,

    ROUND(
        100 * COUNT(*) /
        (
            SELECT COUNT(*)
            FROM users
            WHERE signup_date >= '2026-03-01'
              AND signup_date < '2026-04-01'
        ),
        1
    ) AS signup_share_pct

FROM users

WHERE signup_date >= '2026-03-01'
  AND signup_date < '2026-04-01'

GROUP BY acquisition_channel

ORDER BY signups DESC;


-- ============================================================
-- 3. MONTHLY SIGNUPS BY ACQUISITION CHANNEL
-- ============================================================

/*
Purpose:
Compare the March acquisition mix with other months.
*/

SELECT
    DATE_FORMAT(signup_date, '%Y-%m') AS signup_month,
    acquisition_channel,
    COUNT(*) AS signups

FROM users

GROUP BY
    DATE_FORMAT(signup_date, '%Y-%m'),
    acquisition_channel

ORDER BY
    signup_month,
    signups DESC;


-- ============================================================
-- 4. MARCH SIGNUPS BY COUNTRY
-- ============================================================

/*
Purpose:
Check whether the March campaign was concentrated in a
particular geography.
*/

SELECT
    country,
    COUNT(*) AS signups

FROM users

WHERE signup_date >= '2026-03-01'
  AND signup_date < '2026-04-01'

GROUP BY country

ORDER BY signups DESC;


-- ============================================================
-- 5. MARCH COHORT SUBSCRIPTIONS
-- ============================================================

/*
Connect March users to their subscription records.
*/

SELECT
    s.plan,
    s.is_trial,
    s.price_inr,
    COALESCE(s.promo_code, 'NO PROMO') AS promo_code,
    COUNT(*) AS subscription_rows

FROM subscriptions_clean s

INNER JOIN users u
    ON s.user_id = u.user_id

WHERE u.signup_date >= '2026-03-01'
  AND u.signup_date < '2026-04-01'

GROUP BY
    s.plan,
    s.is_trial,
    s.price_inr,
    COALESCE(s.promo_code, 'NO PROMO')

ORDER BY subscription_rows DESC;


-- ============================================================
-- 6. PROMO CODE USAGE BY MONTH
-- ============================================================

/*
Purpose:
Check whether a promotion was associated with the March
acquisition campaign.
*/

SELECT
    DATE_FORMAT(started_at, '%Y-%m') AS subscription_month,
    COALESCE(promo_code, 'NO PROMO') AS promo_code,
    COUNT(*) AS subscription_rows

FROM subscriptions_clean

GROUP BY
    DATE_FORMAT(started_at, '%Y-%m'),
    COALESCE(promo_code, 'NO PROMO')

ORDER BY
    subscription_month,
    subscription_rows DESC;


-- ============================================================
-- 7. MARCH PROMO USAGE
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
-- 8. JUNE CHURN BY STARTING PRICE
-- ============================================================

/*
Purpose:
Understand the prices associated with subscriptions whose
access ended in June.

IMPORTANT:

This is descriptive only.

It should NOT be interpreted as proof that a particular price
caused churn.
*/

SELECT
    price_inr,
    COUNT(*) AS june_churned

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'

GROUP BY price_inr

ORDER BY june_churned DESC;


-- ============================================================
-- 9. JUNE CHURN BY STARTING PRICE WITH SHARE
-- ============================================================

SELECT
    price_inr,
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

GROUP BY price_inr

ORDER BY june_churned DESC;


-- ============================================================
-- 10. JUNE CHURNERS BY PRICE AND SIGNUP COHORT
-- ============================================================

/*
This separates the price variable from the cohort variable.

It helps determine whether June churners were mainly
associated with older pricing cohorts.
*/

SELECT
    DATE_FORMAT(started_at, '%Y-%m') AS signup_month,
    price_inr,
    COUNT(*) AS june_churned

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01'

GROUP BY
    DATE_FORMAT(started_at, '%Y-%m'),
    price_inr

ORDER BY
    signup_month,
    june_churned DESC;


-- ============================================================
-- 11. JUNE CHURNERS WHO HAD A ₹449 STARTING PRICE
-- ============================================================

/*
This checks whether any June churners entered their subscription
at the new ₹449 price.

This is a diagnostic test.

If the result is zero, June churn cannot be treated as a
direct test of churn among customers who started at ₹449.
*/

SELECT
    COUNT(*) AS june_churn_at_449

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'
  AND price_inr = 449
  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01';


-- ============================================================
-- 12. JUNE CHURNERS WHO STARTED BEFORE THE PRICE CHANGE
-- ============================================================

SELECT
    COUNT(*) AS june_churners_started_before_price_change

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'

  AND started_at < '2026-06-01'

  AND ended_at >= '2026-06-01'
  AND ended_at < '2026-07-01';


-- ============================================================
-- 13. SUBSCRIPTIONS STARTED BEFORE VS AFTER PRICE CHANGE
-- ============================================================

SELECT
    CASE
        WHEN started_at < '2026-06-01'
            THEN 'Before June price change'
        ELSE 'On/after June price change'
    END AS price_period,

    COUNT(*) AS subscriptions

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'

GROUP BY
    CASE
        WHEN started_at < '2026-06-01'
            THEN 'Before June price change'
        ELSE 'On/after June price change'
    END;


-- ============================================================
-- 14. MONTHLY SUBSCRIPTION STARTS BY PRICE
-- ============================================================

/*
This shows when the ₹399 and ₹449 prices entered the
subscription data.
*/

SELECT
    DATE_FORMAT(started_at, '%Y-%m') AS start_month,
    price_inr,
    COUNT(*) AS subscription_starts

FROM subscriptions_clean

WHERE is_trial = 0
  AND plan = 'monthly'

GROUP BY
    DATE_FORMAT(started_at, '%Y-%m'),
    price_inr

ORDER BY
    start_month,
    price_inr;


-- ============================================================
-- 15. JUNE CHURN: MARCH COHORT VS OTHER COHORTS
-- ============================================================

SELECT
    CASE
        WHEN started_at >= '2026-03-01'
         AND started_at < '2026-04-01'
        THEN 'March 2026 cohort'
        ELSE 'Other cohorts'
    END AS cohort_group,

    price_inr,

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
        ELSE 'Other cohorts'
    END,
    price_inr

ORDER BY
    cohort_group,
    june_churned DESC;


-- ============================================================
-- 16. PRICE CHANGE HISTORY FROM PLANS TABLE
-- ============================================================

/*
Use the plans table to verify the official price history rather
than relying only on the subscription records.
*/

SELECT
    plan,
    billing_period,
    list_price_inr,
    effective_from

FROM plans

WHERE plan = 'monthly'

ORDER BY effective_from;


-- ============================================================
-- 17. MONTHLY PRICE TIMELINE
-- ============================================================

SELECT
    plan,
    billing_period,
    list_price_inr,
    effective_from,

    LEAD(effective_from) OVER (
        PARTITION BY plan, billing_period
        ORDER BY effective_from
    ) AS next_effective_from

FROM plans

WHERE plan = 'monthly'

ORDER BY effective_from;


-- ============================================================
-- 18. FINAL PRICE-HYPOTHESIS CHECK
-- ============================================================

/*
INTERPRETATION

The June 1 price increase was:

    ₹399 -> ₹449

However, June churn is based on ended_at.

Customers whose access ended in June largely entered their
subscriptions before June 1.

Therefore, June churn does not provide a clean post-price
experiment.

A June churn increase cannot be interpreted as direct evidence
that customers reacted to ₹449.

The correct future test is:

    Customers actually renewed/exposed to ₹449
                    vs
    Comparable customers under the previous price

Then compare their subsequent renewal/churn behavior.

IMPORTANT:

Do NOT conclude:

    "₹449 did not cause churn."

Instead conclude:

    "The June data does not cleanly isolate the effect of ₹449."

This distinction avoids claiming causality from observational data.
*/


-- ============================================================
-- 19. FINAL BUSINESS EVIDENCE SUMMARY
-- ============================================================

/*
KEY VERIFIED FINDINGS

1. May monthly churn:
       3.7%

2. June monthly churn:
       11.2%

3. Reported June churn:
       ~17%
   The reported number could not be reproduced using the
   specified churn definition.

4. June churned paid monthly subscriptions:
       914

5. March 2026 cohort June churn:
       572

6. March cohort share of June churn:
       62.6%

7. June churn excluding March cohort:
       5.3%

8. Monthly price:
       ₹399 before June
       ₹449 from June 1

9. Interpretation:
       The June spike is heavily concentrated in the March
       acquisition cohort.

10. Price conclusion:
       June data does not cleanly isolate the effect of the
       ₹399 -> ₹449 price increase.

11. Recommendation:
       Do not roll back ₹449 based on June churn alone.
       Measure actual post-price renewal/churn behavior.
*/
