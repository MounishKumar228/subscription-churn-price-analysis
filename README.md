# Subscription Churn & June 2026 Price Impact Analysis

## Business Question

The business reported that monthly churn increased from approximately 4.5% in May to nearly 17% in June after the monthly plan price increased from ₹399 to ₹449 on June 1.

The objective was to:

1. Verify the reported June churn.
2. Identify what actually drove the June increase.
3. Test whether the price increase explains the spike.
4. Recommend whether the price should be rolled back.

---

## Executive Recommendation

### Keep the ₹449 price for now. Do not roll it back based on June churn.

The reported **~17% June churn could not be reproduced** using the specified churn definition.

Using paid monthly subscribers and `ended_at` as the actual access-end date:

- **May churn: 3.7%**
- **June churn: 11.2%**

The June increase is heavily concentrated in the **March 2026 signup cohort**.

Of the **914** paid monthly subscriptions whose access ended in June, **572 came from the March 2026 cohort**.

March was also the month of the acquisition campaign, creating an unusually large cohort. This means a large group of March-acquired subscribers reached their access-end point in June.

The cohort effect is clear:

- June churn including March = **11.2%**
- June churn excluding March = **5.3%**

Therefore, most of the June spike is explained by the March cohort rather than a broad increase across the entire subscriber base.

---

## What About the ₹399 → ₹449 Price Increase?

The June churn data does **not provide a clean test of the price increase**.

The price increased on June 1, but the subscriptions ending in June largely belong to customers who entered the service before the price change. Therefore, June churn cannot be interpreted as a direct measure of customers reacting to ₹449.

This does **not prove that the price increase has no effect**.

The price effect should instead be evaluated when customers actually reach a renewal/payment point at ₹449.

### Recommendation

**Do not roll back the price on September 1 based on the June churn spike.**

Keep ₹449 and evaluate subsequent renewal/churn among customers actually exposed to the new price.

A rollback should only be considered if the post-price cohort shows a persistent incremental churn increase large enough to outweigh the additional ₹50 monthly revenue per retained subscriber.

---

## Key Findings

| Metric | Result |
|---|---:|
| Reported June churn | ~17% |
| Verified June churn | **11.2%** |
| May churn | **3.7%** |
| March cohort June churn | **572** |
| June churn excluding March cohort | **5.3%** |
| Monthly price change | **₹399 → ₹449** |

---

## Why March Matters

The March acquisition campaign produced an unusually large signup cohort.

When June churners are grouped by their subscription start month, the March 2026 cohort is the largest contributor:

```text
March 2026 cohort → 572 June churns
