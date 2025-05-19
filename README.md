# DataAnalytics-Assessment

# Q1. High-Value Customers with Multiple Products

## Approach:
I structured the query using Common Table Expressions (CTEs) for clarity, maintainability, and separation of logic. [cite: 1]
Each CTE isolates a specific segment of users: [cite: 2]
* `savings_plans`: captures users with at least one regular savings plan that have received confirmed deposits. [cite: 2]
* `investment_plans`: captures users with at least one funded investment plan. [cite: 3]
* `cross_sell_customers`: joins the two above to find users who have at least one funded savings and investment plan. [cite: 4]
Only transactions with `confirmed_amount > 0` and `status = 'success'` are included. [cite: 5]
This ensures that only genuinely funded and successfully processed transactions are considered, filtering out failed or pending transactions. [cite: 6]
The final `SELECT` statement enriches the results with customer names from the `users_customuser` table. [cite: 7]
I ensured to convert from Kobo to Naira. [cite: 8]
I then sorted by `total_deposits` in descending order to show the highest value customers first.

## Challenges:
I encountered some difficulty in determining what qualifies as "funded." [cite: 9]
Should I count all created plans or only those with actual money deposited? [cite: 10]

## Resolution:
I examined the `savings_savingsaccount` table and concluded that the `confirmed_amount` field (when greater than 0 and having a transaction status of 'success') accurately reflects real deposits. [cite: 11]
Therefore, I explicitly filtered using these criteria to ensure only completed inflows were included. [cite: 12]
I also realized that some customers might have multiple transactions for the same plan. [cite: 13]
Thus, I needed to count distinct plans rather than rows and sum deposits correctly. [cite: 14]

## Resolution:
I used `COUNT(DISTINCT p.id)` to count unique funded plans per user, combined with `SUM(s.confirmed_amount)` for the total deposit value, recognizing that deposits can occur in multiple transactions for the same plan. [cite: 15]

# Q2. Transaction Frequency Analysis

## Approach:
I created a solution that uses a CTE to calculate transactions per month for each customer, then categorizes them based on frequency thresholds. [cite: 16]

## Here is the process:
The first CTE counts monthly transactions for each customer. [cite: 17]
The next CTE then calculates the average monthly transactions per customer. [cite: 17]
I then categorized customers based on transaction frequency. [cite: 17]
I then calculated the final average in the main query by dividing the total transactions per month by the count of customers in each frequency category. [cite: 17]

## Challenges:
**Statistical Accuracy**: The initial approach I took was to calculate an average of averages to get the final average, which can be statistically problematic. [cite: 18]

## Resolution:
I resolved this by redesigning the final aggregation step to properly sum individual averages and divide by customer count. [cite: 19]
After I finished the penultimate draft of the query, I noticed that alphabetical ordering of categories would confuse readers. [cite: 20]

## Resolution:
I resolved this by using a `CASE` expression in the `ORDER BY` statement to define a custom logical sort order. [cite: 21]

# Q3. Account Inactivity Alert

## Approach:
I identified the most recent inflow transactions per plan. [cite: 22]
I then calculated days since last activity and identified accounts that have been inactive in more than a year. [cite: 23]

## Challenges:
**Table Restrictions**: I initially included a join with the `users` table; [cite: 24]
however, I had to revise my approach due to the requirement to use only the two designated tables. [cite: 25]