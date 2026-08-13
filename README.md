# Subscription Churn & June 2026 Price Impact Analysis

## Business Question

The business reported that monthly churn increased from approximately **4.5% in May to nearly 17% in June** after the monthly plan price increased from **₹399 to ₹449 on June 1**.

The objective of this analysis was to:

1. Verify the reported June churn.
2. Calculate May and June churn using the stated business definition.
3. Identify what actually drove the June churn increase.
4. Test whether the June price increase explains the spike.
5. Recommend whether the monthly price should be rolled back.

---

# Executive Recommendation

## Keep the ₹449 price for now. Do not roll it back based on the June churn spike.

The reported **~17% June churn could not be reproduced** using the specified churn definition.

Using paid monthly subscribers and `ended_at` as the actual access-end date:

- **May 2026 churn: 3.7%**
- **June 2026 churn: 11.2%**

June churn was therefore higher than May, but the increase was heavily concentrated in the **March 2026 signup cohort**.

Of the **914** paid monthly subscriptions whose access ended in June, **572 came from the March 2026 cohort**.

March also coincided with the acquisition campaign and produced an unusually large signup cohort. This means a large group of March-acquired subscribers reached their access-end point in June.

When the March 2026 cohort is removed from both the numerator and denominator:

**June churn falls from 11.2% to 5.3%.**

This indicates that the June spike was primarily a **cohort effect**, rather than evidence of a broad-based increase in churn across the subscriber base.

---

# What About the ₹399 → ₹449 Price Increase?

The June churn data does **not provide a clean test of the price increase**.

The price changed on **June 1**, while churn is measured using the date when customer access actually ended.

Many customers whose access ended in June had entered their subscription before the price change. Therefore, June churn cannot be interpreted as a direct measure of customers reacting to the new ₹449 price.

This does **not prove that the price increase has no effect**.

The price effect should instead be evaluated among customers whose renewal or payment actually occurred at ₹449.

## Recommendation

**Do not roll back the monthly price on September 1 based on June churn alone.**

Keep the monthly price at **₹449** and evaluate subsequent renewal/churn among customers actually exposed to the new price.

A rollback should only be considered if the post-price cohort shows a persistent incremental churn increase large enough to outweigh the additional **₹50 monthly revenue per retained subscriber**.

---

# Key Findings

| Metric | Result |
|---|---:|
| Reported June churn | ~17% |
| Verified June churn | **11.2%** |
| May churn | **3.7%** |
| June churned subscriptions | **914** |
| March cohort June churn | **572** |
| June churn excluding March cohort | **5.3%** |
| Monthly price before June | **₹399** |
| Monthly price from June | **₹449** |
| Price increase | **₹50 / 12.5%** |

---

# What I Tested

## 1. Was the reported 17% June churn correct?

**No.**

Using the churn definition supplied in the assessment:

> Churn rate = subscriptions whose access ended during the month ÷ subscriptions active at the first instant of that month

For paid monthly subscribers:

**June churn = 11.2%**

The reported ~17% figure could not be reproduced.

---

## 2. Was June churn broad-based?

**No.**

June churn was heavily concentrated in the **March 2026 signup cohort**.

The March cohort contributed:

**572 of the 914 June churned subscriptions.**

That is approximately **62.6% of June churn**.

---

## 3. What happened in March?

March coincided with a major acquisition campaign and produced an unusually large signup cohort.

The acquisition channel analysis shows that **paid social was the dominant source of March signups**.

This created a large group of subscribers who subsequently reached their access-end dates in June.

---

## 4. Does removing the March cohort explain the June spike?

Largely, yes.

June churn:

**11.2%**

June churn excluding March:

**5.3%**

Therefore, removing the March cohort reduces June churn by **5.9 percentage points**.

This shows that the March cohort was the main contributor to the unusual June result.

---

## 5. Did the June data prove that ₹449 caused the churn spike?

**No.**

The June-ending subscription population does not provide a clean post-price experiment.

The price changed on June 1, but customers ending in June largely represent subscriptions that started before the price change.

Therefore, the June churn increase should not be interpreted as a direct estimate of the effect of ₹449.

---

# Methodology

## Churn Definition

The analysis follows the exact definition provided in the assessment:

```text
Monthly Churn Rate =
Paid monthly subscriptions whose access ended during the month
----------------------------------------------------------------
Paid monthly subscriptions active at the first instant of the month
