USE Financial_Transactions2;
GO

CREATE TABLE transactions_data(
    id BIGINT PRIMARY KEY,
    date DATETIME,
    client_id BIGINT,
    card_id BIGINT,
    amount FLOAT,
    use_chip VARCHAR(50),
    merchant_id BIGINT,
    merchant_city VARCHAR(100),
    merchant_state VARCHAR(50),
    zip VARCHAR(20),
    mcc INT,
    errors VARCHAR(255),
    is_online BIT,
    merchant_category VARCHAR(100),
    is_fraud BIT
);
--DROP TABLE transactions_data;
SELECT COUNT(*) AS RowsInTrans FROM dbo.transactions_data;
GO

-- ربط الكارد بالمستخدم
ALTER TABLE cards_data_clean
ADD CONSTRAINT fk_cards_user
FOREIGN KEY (client_id) REFERENCES users_data_clean(id);

-- ربط العمليات بالمستخدم والكارد
ALTER TABLE Transactions_data
ADD CONSTRAINT fk_transactions_user
FOREIGN KEY (client_id) REFERENCES users_data_clean(id),
    CONSTRAINT fk_transactions_card
FOREIGN KEY (card_id) REFERENCES Cards_data_clean(id);


-- التأكد من نوع الأعمدة
EXEC sp_help 'users_data_clean';
EXEC sp_help 'Transactions_data';
EXEC sp_help 'Cards_data_clean';

-- تحويل client_id من bigint إلى smallint
ALTER TABLE Transactions_data
ALTER COLUMN client_id SMALLINT;
-- تحويل card_id من bigint إلى smallint
ALTER TABLE Transactions_data
ALTER COLUMN card_id SMALLINT;



-- عدد ال CARDS لكل CLIENT
SELECT u.id AS client_id, COUNT(c.id) AS num_cards
FROM users_data_clean u
LEFT JOIN cards_data_clean c ON u.id = c.client_id
GROUP BY u.id
ORDER BY num_cards DESC;

-- ايه انواع ال CARDS لكل USER
SELECT u.id AS client_id, c.card_type, COUNT(*) AS count_per_type
FROM users_data_clean u
JOIN cards_data_clean c ON u.id = c.client_id
GROUP BY u.id, c.card_type
ORDER BY u.id, count_per_type DESC;

-- ال AVG لكل CARD
SELECT c.id AS card_id, c.card_type, AVG(t.amount) AS avg_amount
FROM cards_data_clean c
LEFT JOIN transactions_data t ON c.id = t.card_id
GROUP BY c.id, c.card_type
ORDER BY avg_amount DESC;

-- TOTAL ANALYSIS
SELECT u.id AS client_id, u.gender, u.birth_year,
       COUNT(DISTINCT c.id) AS num_cards,
       COUNT(t.id) AS total_transactions,
       SUM(CASE WHEN t.is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_count
FROM users_data_clean u
LEFT JOIN cards_data_clean c ON u.id = c.client_id
LEFT JOIN transactions_data t ON c.id = t.card_id
GROUP BY u.id, u.gender, u.birth_year
ORDER BY fraud_count DESC;

-- CARDS TYPES & USE CHIP & NUM OF TRANS
SELECT c.card_type, t.use_chip, COUNT(*) AS num_transactions
FROM cards_data_clean c
JOIN transactions_data t ON c.id = t.card_id
GROUP BY c.card_type, t.use_chip
ORDER BY c.card_type, num_transactions DESC;

--  عمليات ال FRAUD على حسب ال  CARD TYPE
SELECT c.card_type, t.is_fraud, COUNT(*) AS count_transactions
FROM cards_data_clean c
JOIN transactions_data t ON c.id = t.card_id
GROUP BY c.card_type, t.is_fraud
ORDER BY c.card_type, t.is_fraud DESC;


-- TOTAL AMOUNT
SELECT u.id AS client_id, c.card_type, SUM(t.amount) AS total_amount
FROM users_data_clean u
JOIN cards_data_clean c ON u.id = c.client_id
JOIN transactions_data t ON c.id = t.card_id
GROUP BY u.id, c.card_type
ORDER BY total_amount DESC;


-- أعلى المستخدمين نشاطًا مع الFRAUD لكل بطاقة
SELECT u.id AS client_id, c.id AS card_id, c.card_type,
       COUNT(t.id) AS total_transactions,
       SUM(CASE WHEN t.is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_count
FROM users_data_clean u
JOIN cards_data_clean c ON u.id = c.client_id
JOIN transactions_data t ON c.id = t.card_id
GROUP BY u.id,  c.id, c.card_type
ORDER BY fraud_count DESC;
