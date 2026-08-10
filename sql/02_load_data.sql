LOAD DATA LOCAL INFILE 'C:/path/to/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    user_id,
    signup_date,
    acquisition_channel,
    country
);

LOAD DATA LOCAL INFILE 'C:/path/to/plans.csv'
INTO TABLE plans
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    plan,
    billing_period,
    list_price_inr,
    effective_from
);

LOAD DATA LOCAL INFILE 'C:/path/to/subscriptions(1).csv'
INTO TABLE subscriptions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    subscription_id,
    user_id,
    plan,
    is_trial,
    started_at,
    price_inr,
    @promo_code,
    @cancelled_at,
    @ended_at,
    status
)
SET
    promo_code = NULLIF(@promo_code, ''),
    cancelled_at = NULLIF(@cancelled_at, ''),
    ended_at = NULLIF(@ended_at, '');
