CREATE TABLE [dbo].[XXX_PAYMENT_TRANSACTION_20240930] (
    [CODE]                     NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]              NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]              NVARCHAR (250)  NOT NULL,
    [PAYMENT_TRANSACTION_DATE] DATETIME        NOT NULL,
    [PAYMENT_AMOUNT]           DECIMAL (18, 2) NOT NULL,
    [REMARK]                   NVARCHAR (4000) NOT NULL,
    [PAYMENT_STATUS]           NVARCHAR (50)   NOT NULL,
    [TO_BANK_NAME]             NVARCHAR (50)   NOT NULL,
    [TO_BANK_ACCOUNT_NO]       NVARCHAR (50)   NOT NULL,
    [TO_BANK_ACCOUNT_NAME]     NVARCHAR (250)  NOT NULL,
    [DATE_FLAG]                DATETIME        NULL,
    [CRE_DATE]                 DATETIME        NULL,
    [CRE_BY]                   NVARCHAR (50)   NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (50)   NULL,
    [MOD_DATE]                 DATETIME        NULL,
    [MOD_BY]                   NVARCHAR (50)   NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (50)   NULL,
    [FILE_NAME]                NVARCHAR (250)  NULL,
    [PATHS]                    NVARCHAR (250)  NULL
);

