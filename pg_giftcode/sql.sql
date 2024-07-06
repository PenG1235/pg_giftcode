CREATE TABLE IF NOT EXISTS pg_giftcodes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(255) NOT NULL,
    reward VARCHAR(255) NOT NULL,
    amount INT DEFAULT 1,
    reward_type VARCHAR(50) NOT NULL,
    max_redeem INT DEFAULT 1,
    current_redeem INT DEFAULT 0,
    expire_at DATETIME
);

CREATE TABLE IF NOT EXISTS pg_user_giftcodes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(255) NOT NULL,
    code VARCHAR(255) NOT NULL
);
