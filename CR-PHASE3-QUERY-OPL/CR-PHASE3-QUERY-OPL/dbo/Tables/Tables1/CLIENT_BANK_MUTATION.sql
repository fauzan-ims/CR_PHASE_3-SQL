CREATE TABLE [dbo].[CLIENT_BANK_MUTATION] (
    [ID]                       BIGINT          IDENTITY (1, 1) NOT NULL,
    [CLIENT_CODE]              NVARCHAR (50)   NOT NULL,
    [CLIENT_BANK_CODE]         NVARCHAR (50)   NOT NULL,
    [MONTH]                    NVARCHAR (15)   NOT NULL,
    [YEAR]                     NVARCHAR (4)    NOT NULL,
    [DEBIT_TRANSACTION_COUNT]  INT             NOT NULL,
    [DEBIT_AMOUNT]             DECIMAL (18, 2) NOT NULL,
    [CREDIT_TRANSACTION_COUNT] INT             NOT NULL,
    [CREDIT_AMOUNT]            DECIMAL (18, 2) NOT NULL,
    [BALANCE_AMOUNT]           DECIMAL (18, 2) NOT NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL
);

