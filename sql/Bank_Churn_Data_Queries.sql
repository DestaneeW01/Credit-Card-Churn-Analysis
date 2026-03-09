USE Bank_Churn;
GO

-- Total customers and churn rate
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
    CAST(SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate_percent
FROM BankChurn


-- Average key metrics by churn status
SELECT 
    churn_status,
    AVG(transaction_count) AS avg_transaction_count,
    AVG(transaction_change_ratio) AS avg_transaction_change_ratio,
    AVG(contact_count_12_months) AS avg_contact_count
FROM BankChurn
GROUP BY churn_status


-- Segment by transaction count
SELECT 
    CASE 
        WHEN transaction_count < 40 THEN 'Low Activity'
        WHEN transaction_count BETWEEN 40 AND 70 THEN 'Medium Activity'
        ELSE 'High Activity'
    END AS activity_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned,
    CAST(SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate_percent
FROM BankChurn
GROUP BY 
    CASE 
        WHEN transaction_count < 40 THEN 'Low Activity'
        WHEN transaction_count BETWEEN 40 AND 70 THEN 'Medium Activity'
        ELSE 'High Activity'
    END
ORDER BY churn_rate_percent DESC;


-- Top churn drivers table
SELECT
    transaction_count,
    transaction_change_ratio,
    contact_count_12_months,
    RANK() OVER (ORDER BY transaction_count ASC, transaction_change_ratio ASC) AS churn_risk_rank
FROM BankChurn

-- Churn rate by income_category
SELECT 
    income_category,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
    CAST(
        SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS churn_rate_percent
FROM BankChurn
GROUP BY income_category
ORDER BY churn_rate_percent DESC;


--- Churn by transaction_count
SELECT 
    CASE 
        WHEN transaction_count < 40 THEN 'High Risk (Low Activity)'
        WHEN transaction_count BETWEEN 40 AND 70 THEN 'Moderate Activity'
        ELSE 'Low Risk (High Activity)'
    END AS activity_segment,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned,

    CAST(
        SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS churn_rate_percent

FROM BankChurn
GROUP BY 
    CASE 
        WHEN transaction_count < 40 THEN 'High Risk (Low Activity)'
        WHEN transaction_count BETWEEN 40 AND 70 THEN 'Moderate Activity'
        ELSE 'Low Risk (High Activity)'
    END
ORDER BY churn_rate_percent DESC;

--- Churn by transaction_change_ratio
SELECT 
    CASE 
        WHEN transaction_change_ratio < 0.6 THEN 'Declining Usage'
        WHEN transaction_change_ratio BETWEEN 0.6 AND 0.8 THEN 'Stable Usage'
        ELSE 'Growing Usage'
    END AS usage_trend,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned,

    CAST(
        SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS churn_rate_percent

FROM BankChurn
GROUP BY 
    CASE 
        WHEN transaction_change_ratio < 0.6 THEN 'Declining Usage'
        WHEN transaction_change_ratio BETWEEN 0.6 AND 0.8 THEN 'Stable Usage'
        ELSE 'Growing Usage'
    END
ORDER BY churn_rate_percent DESC;


---Churn by contact_count_12_months
SELECT 
    contact_count_12_months,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned,
    CAST(
        SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS churn_rate_percent
FROM BankChurn
GROUP BY contact_count_12_months
ORDER BY contact_count_12_months;



--- Calculate percentile-based risk buckets
SELECT
    transaction_count,
    transaction_change_ratio,
    contact_count_12_months,
    NTILE(3) OVER (
        ORDER BY transaction_count ASC, transaction_change_ratio ASC
    ) AS risk_bucket
FROM BankChurn


--- Make Readable Labels
SELECT
    transaction_count,
    transaction_change_ratio,
    contact_count_12_months,
    CASE 
        WHEN NTILE(3) OVER (ORDER BY transaction_count ASC, transaction_change_ratio ASC) = 1 THEN 'High Risk'
        WHEN NTILE(3) OVER (ORDER BY transaction_count ASC, transaction_change_ratio ASC) = 2 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END AS churn_risk_segment
FROM BankChurn


--- Aggregate for Dashboards
;WITH risk_cte AS (
    SELECT
        churn_status,
        CASE 
            WHEN NTILE(3) OVER (ORDER BY transaction_count ASC, transaction_change_ratio ASC) = 1 THEN 'High Risk'
            WHEN NTILE(3) OVER (ORDER BY transaction_count ASC, transaction_change_ratio ASC) = 2 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS churn_risk_segment
    FROM BankChurn
)
SELECT
    churn_risk_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
    CAST(SUM(CASE WHEN churn_status = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate_percent
FROM risk_cte
GROUP BY churn_risk_segment
ORDER BY churn_rate_percent DESC;


--- Aggregate for Dashboards
;WITH risk_cte AS (
    SELECT
        churn_status,
        transaction_count,
        transaction_change_ratio,
        contact_count_12_months,
        CASE 
            WHEN NTILE(3) OVER (ORDER BY transaction_count ASC, transaction_change_ratio ASC) = 1 THEN 'High Risk'
            WHEN NTILE(3) OVER (ORDER BY transaction_count ASC, transaction_change_ratio ASC) = 2 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS churn_risk_segment
    FROM BankChurn
)
SELECT *
FROM risk_cte;
