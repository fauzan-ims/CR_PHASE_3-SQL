CREATE TABLE [dbo].[RPT_SURVEY_BANK_MUTATION] (
    [USER_ID]                  NVARCHAR (50)   NOT NULL,
    [CLIENT_CODE]              NVARCHAR (50)   NULL,
    [CLIENT_BANK_CODE]         NVARCHAR (50)   NULL,
    [MONTH]                    NVARCHAR (15)   NULL,
    [YEAR]                     NVARCHAR (4)    NULL,
    [DEBIT_TRANSACTION_COUNT]  INT             NULL,
    [DEBIT_AMOUNT]             DECIMAL (18, 2) NULL,
    [CREDIT_TRANSACTION_COUNT] INT             NULL,
    [CREDIT_AMOUNT]            DECIMAL (18, 2) NULL,
    [BALANCE_AMOUNT]           DECIMAL (18, 2) NULL
);

