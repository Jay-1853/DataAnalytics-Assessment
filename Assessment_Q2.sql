-- This CTE counts transactions per customer per month
WITH monthly_transactions AS (
    SELECT
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m-01') AS month,
        COUNT(*) AS transaction_count
    FROM
        savings_savingsaccount
    WHERE
        transaction_status = 'success'
    GROUP BY
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m-01')
),

-- Calculates average transactions per month for each customer
customer_avg AS (
    SELECT
        owner_id,
        AVG(transaction_count) AS avg_txn_per_month
    FROM
        monthly_transactions
    GROUP BY
        owner_id
),

-- Categorizes customers based on transaction frequency
customer_classification AS (
    SELECT
        CASE
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        owner_id,
        avg_txn_per_month
    FROM 
        customer_avg
),

-- Groups by frequency category to get customer counts
category_summary AS (
    SELECT
        frequency_category,
        COUNT(*) AS customer_count,
        SUM(avg_txn_per_month) AS total_txn_per_month
    FROM
        customer_classification
    GROUP BY
        frequency_category
)
-- Calculates the final average transactions per month per category
SELECT
    frequency_category,
    customer_count,
    ROUND(total_txn_per_month / customer_count, 1) AS avg_transactions_per_month
FROM
    category_summary
ORDER BY
    CASE
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        WHEN frequency_category = 'Low Frequency' THEN 3
    END;