-- This CTE identifies customers with at least one savings plan
WITH savings_plans AS (
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS savings_count,
        SUM(s.confirmed_amount) AS savings_deposits
    FROM 
        plans_plan p
    JOIN 
        savings_savingsaccount s ON p.id = s.plan_id
    WHERE 
        p.is_regular_savings = 1
        AND s.transaction_status = 'success' -- Filters for valid and successful transactions
        AND s.confirmed_amount > 0  -- Filters for funded account
    GROUP BY 
        p.owner_id
    HAVING 
        COUNT(DISTINCT p.id) > 0
),

-- This CTE identifies customers with at least one investment plan
investment_plans AS (
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS investment_count,
        SUM(s.confirmed_amount) AS investment_deposits
    FROM 
        plans_plan p
    JOIN 
        savings_savingsaccount s ON p.id = s.plan_id
    WHERE 
        p.is_a_fund = 1
        AND s.transaction_status = 'success' -- Filters for valid and successful transactions
        AND s.confirmed_amount > 0 -- Filters for funded account
    GROUP BY 
        p.owner_id
    HAVING 
        COUNT(DISTINCT p.id) > 0
),

-- Joins the savings and investment CTEs
cross_sell_customers AS (
    SELECT 
        sp.owner_id,
        sp.savings_count,
        ip.investment_count,
        (sp.savings_deposits + ip.investment_deposits) AS total_deposits
    FROM 
        savings_plans sp
    JOIN 
        investment_plans ip ON sp.owner_id = ip.owner_id
)

-- Main query brings in the users tables to get customer names 
SELECT 
    csc.owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    csc.savings_count,
    csc.investment_count,
    ROUND(csc.total_deposits / 100, 2) AS total_deposits -- Converts kobo to Naira with 2 decimal places
FROM    
    cross_sell_customers csc
JOIN 
    users_customuser u ON csc.owner_id = u.id
ORDER BY 
    csc.total_deposits DESC;