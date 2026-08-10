# Subscription Churn & Price Analysis

## Executive Recommendation

**Do not roll back the ₹449 monthly price based on the June churn spike.**

The reported **17% June churn is not supported by the subscription data**. Using `ended_at` as the actual access-end date, excluding trial subscriptions and removing exact duplicate records, June paid monthly-plan churn was **11.17%**, compared with **3.71% in May**.

More importantly, the June increase was primarily a **cohort effect from the March acquisition campaign**, rather than evidence that the June 1 price increase caused the spike.

## What happened

March was an abnormal acquisition month. New-user acquisition increased to **3,423 users**, compared with **1,442 in February** and **1,488 in April**. Paid social represented approximately **77% of March acquisition**, compared with roughly 20% in surrounding months.

The March campaign also created a large `LAUNCH60` subscription cohort at **₹160**, substantially below the normal ₹399 monthly price. When these subscriptions reached their end dates in June, they created a large concentration of churn.

Of the **914 monthly subscriptions that ended in June**, **572 (62.6%) came from subscriptions started in March**. The March cohort's June churn was approximately **32.24%**, far above the surrounding cohorts.

The `LAUNCH60` group alone accounted for **516 June monthly ends (56.5%)**.

## Why the ₹449 price increase is not proven to be the cause

The business hypothesis is that the June 1 price increase from **₹399 to ₹449** caused June churn.

The data does not support using June churn as that causal test.

The subscriptions that actually ended in June were subscribed at the previous prices/promotional prices. In particular, **none of the June-ended monthly subscriptions had a ₹449 starting price**. Therefore, the June churn spike cannot be directly attributed to customers being charged ₹449.

There is also an important timing distinction: `cancelled_at` records when a customer clicked cancel, while `ended_at` records when their paid access actually stopped. Churn analysis therefore uses `ended_at`.

## Recommendation

**Keep the monthly price at ₹449 for now. Do not roll it back on September 1 based on the June churn figure.**

The evidence indicates that June was dominated by a March campaign cohort reaching its subscription end date. Rolling the price back would give up the additional ₹50 of monthly revenue without addressing the main driver of June churn.

The next decision should be based on a clean post-price cohort analysis: compare customers actually exposed to ₹449 against comparable pre-price customers using renewal/churn and revenue retention. A rollback should only be considered if the incremental churn caused by ₹449 is persistent and large enough to outweigh the additional revenue per retained subscriber.

## Methodology

* Removed exact duplicate subscription records before analysis.
* Excluded `is_trial = 1` rows from paid churn calculations.
* Used `ended_at`, not `cancelled_at`, to measure actual churn.
* Calculated churn from subscriptions active at the beginning of each month.
* Analyzed June churn by subscription-start cohort.
* Connected the March cohort to acquisition channel and `LAUNCH60`.
* Kept the raw subscription table separate from the cleaned analytical dataset.

See the `/sql` directory for the complete analysis and reproducible queries.
