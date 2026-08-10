CREATE DATABASE IF NOT EXISTS subscriptionanalysis;

USE subscriptionanalysis;

DROP TABLE IF EXISTS plans;

CREATE TABLE plans (
    plan VARCHAR(10) NOT NULL,
    billing_period VARCHAR(10) NOT NULL,
    list_price_inr INT NOT NULL,
    effective_from DATE NOT NULL,
    PRIMARY KEY (plan, effective_from)
);

DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id VARCHAR(10) NOT NULL,
    signup_date DATE NOT NULL,
    acquisition_channel VARCHAR(30),
    country VARCHAR(5),
    PRIMARY KEY (user_id)
);

DROP TABLE IF EXISTS subscriptions;

CREATE TABLE subscriptions (
    subscription_row_id BIGINT AUTO_INCREMENT,
    subscription_id VARCHAR(15) NOT NULL,
    user_id VARCHAR(10) NOT NULL,
    plan VARCHAR(10) NOT NULL,
    is_trial TINYINT NOT NULL,
    started_at DATETIME NOT NULL,
    price_inr INT NOT NULL,
    promo_code VARCHAR(30),
    cancelled_at DATETIME NULL,
    ended_at DATETIME NULL,
    status VARCHAR(15) NOT NULL,

    PRIMARY KEY (subscription_row_id),

    INDEX idx_subscription_id (subscription_id),
    INDEX idx_user_id (user_id),
    INDEX idx_started_at (started_at),
    INDEX idx_status (status)
);
