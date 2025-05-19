-- This CTE finds the last inflow transaction date for each plan
WITH last_inflow_transactions AS (
    SELECT
        plan_id,
        owner_id,
        MAX(transaction_date) AS last_transaction_date
    FROM
        savings_savingsaccount
    WHERE
        transaction_status = 'success'
        AND confirmed_amount > 0
    GROUP BY
        plan_id, owner_id
),

-- This CTE identifies inactive accounts and calculates inactivity days
inactive_accounts AS (
    SELECT
        p.id AS plan_id,
        p.owner_id,
        CASE
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Other'
        END AS type,
        lit.last_transaction_date,
        DATEDIFF(CURDATE(), lit.last_transaction_date) AS inactivity_days
    FROM
        plans_plan p
    LEFT JOIN
        last_inflow_transactions lit ON p.id = lit.plan_id
    WHERE
        p.status_id = 2  -- Assuming status_id 2 means active
        AND p.is_deleted = 0
        AND DATEDIFF(CURDATE(), lit.last_transaction_date) > 365  -- More than 1 year inactive
)

SELECT
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    inactivity_days
FROM
    inactive_accounts
ORDER BY
    inactivity_days DESC;