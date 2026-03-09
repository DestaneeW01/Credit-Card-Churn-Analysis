USE Bank_Churn;
GO

/*-------------------------------------------------
  Drop tables if they already exist
--------------------------------------------------*/
IF OBJECT_ID('dbo.BankChurn', 'U') IS NOT NULL
    DROP TABLE dbo.BankChurn;

IF OBJECT_ID('dbo.BankChurn_Stage', 'U') IS NOT NULL
    DROP TABLE dbo.BankChurn_Stage;
GO

/*-------------------------------------------------
  Final table (typed schema)
--------------------------------------------------*/
CREATE TABLE dbo.BankChurn
(
    churn_status               NVARCHAR(50),
    customer_age               INT,
    gender                     NVARCHAR(10),
    dependent_count            INT,
    education_level            NVARCHAR(50),
    marital_status             NVARCHAR(50),
    income_category            NVARCHAR(50),
    card_category              NVARCHAR(50),
    months_on_book             INT,
    total_relationship_count   INT,
    months_inactive_12_mon     INT,
    contact_count_12_months    INT,
    credit_limit               DECIMAL(18,2),
    total_revolving_bal        DECIMAL(18,2),
    avg_open_to_buy            DECIMAL(18,2),
    total_amt_chng_q4_q1       DECIMAL(10,4),
    total_trans_amt            DECIMAL(18,2),
    transaction_count          INT,
    transaction_change_ratio   DECIMAL(10,4),
    avg_utilization_ratio      DECIMAL(10,4),
    churn_flag                 INT
);
GO

/*-------------------------------------------------
  Staging table (ALL MAX to prevent truncation)
--------------------------------------------------*/
CREATE TABLE dbo.BankChurn_Stage
(
    churn_status               NVARCHAR(MAX),
    customer_age               NVARCHAR(MAX),
    gender                     NVARCHAR(MAX),
    dependent_count            NVARCHAR(MAX),
    education_level            NVARCHAR(MAX),
    marital_status             NVARCHAR(MAX),
    income_category            NVARCHAR(MAX),
    card_category              NVARCHAR(MAX),
    months_on_book             NVARCHAR(MAX),
    total_relationship_count   NVARCHAR(MAX),
    months_inactive_12_mon     NVARCHAR(MAX),
    contact_count_12_months    NVARCHAR(MAX),
    credit_limit               NVARCHAR(MAX),
    total_revolving_bal        NVARCHAR(MAX),
    avg_open_to_buy            NVARCHAR(MAX),
    total_amt_chng_q4_q1       NVARCHAR(MAX),
    total_trans_amt            NVARCHAR(MAX),
    transaction_count          NVARCHAR(MAX),
    transaction_change_ratio   NVARCHAR(MAX),
    avg_utilization_ratio      NVARCHAR(MAX),
    churn_flag                 NVARCHAR(MAX)
);
GO

/*-------------------------------------------------
  BULK INSERT (explicit delimiters – stable)
--------------------------------------------------*/
BULK INSERT dbo.BankChurn_Stage
FROM 'C:\Imports\bank_churn_clean.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK,
    CODEPAGE = '65001'
);
GO

/*-------------------------------------------------
  Insert into final table with safe conversion
--------------------------------------------------*/
INSERT INTO dbo.BankChurn
SELECT
    churn_status,
    TRY_CONVERT(INT, customer_age),
    gender,
    TRY_CONVERT(INT, dependent_count),
    education_level,
    marital_status,
    income_category,
    card_category,
    TRY_CONVERT(INT, months_on_book),
    TRY_CONVERT(INT, total_relationship_count),
    TRY_CONVERT(INT, months_inactive_12_mon),
    TRY_CONVERT(INT, contact_count_12_months),
    TRY_CONVERT(DECIMAL(18,2), credit_limit),
    TRY_CONVERT(DECIMAL(18,2), total_revolving_bal),
    TRY_CONVERT(DECIMAL(18,2), avg_open_to_buy),
    TRY_CONVERT(DECIMAL(10,4), total_amt_chng_q4_q1),
    TRY_CONVERT(DECIMAL(18,2), total_trans_amt),
    TRY_CONVERT(INT, transaction_count),
    TRY_CONVERT(DECIMAL(10,4), transaction_change_ratio),
    TRY_CONVERT(DECIMAL(10,4), avg_utilization_ratio),
    TRY_CONVERT(INT, churn_flag)
FROM dbo.BankChurn_Stage;
GO

/*-------------------------------------------------
  Sanity check
--------------------------------------------------*/
SELECT COUNT(*) AS RowsLoaded FROM dbo.BankChurn;
SELECT TOP 10 * FROM dbo.BankChurn;