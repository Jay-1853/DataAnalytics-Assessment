-- This CTE aggregates transaction data for each customer
WITH customer_transactions AS (
    SELECT
        s.owner_id AS customer_id,
        COUNT(*) AS total_transactions,
        SUM(s.confirmed_amount) AS total_transaction_value,
        AVG(s.confirmed_amount) AS avg_transaction_value
    FROM
        savings_savingsaccount s
    WHERE
        s.transaction_status = 'success'
    GROUP BY
        s.owner_id
),
-- Calculates each customer's tenure in months and filters for active users only
customer_tenure AS (
    SELECT
        id AS customer_id,
        first_name,
        last_name,
        TIMESTAMPDIFF(MONTH, date_joined, CURDATE()) AS tenure_months
    FROM
        users_customuser
    WHERE
        is_active = 1
)

-- This main query joins the two previous CTEs to merge transaction data with tenure information
SELECT
    ct.customer_id,
    CONCAT(cten.first_name, ' ', cten.last_name) AS name,
    cten.tenure_months,
    ct.total_transactions,
    ROUND(
        ((ct.total_transactions / cten.tenure_months) * 12 * (ct.avg_transaction_value * 0.001)) / 100, 
        2
    ) AS estimated_clv -- Calculates CLV and converts the kobo values to Naira. Note: profit_per_transaction is 0.1% of the transaction value
FROM
    customer_transactions ct
JOIN
    customer_tenure cten ON ct.customer_id = cten.customer_id
WHERE
    cten.tenure_months > 0  -- This is to avoid division by zero
ORDER BY
    estimated_clv DESC; -- Order CLV from highest to lowest