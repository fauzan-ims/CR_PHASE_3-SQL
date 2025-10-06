CREATE TABLE [dbo].[BACKUP_AGREEMENT_DEPOSIT_HISTORY] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [BRANCH_CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]            NVARCHAR (250)  NOT NULL,
    [AGREEMENT_DEPOSIT_CODE] NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]           NVARCHAR (50)   NOT NULL,
    [DEPOSIT_TYPE]           NVARCHAR (15)   NOT NULL,
    [TRANSACTION_DATE]       DATETIME        NOT NULL,
    [ORIG_AMOUNT]            DECIMAL (18, 2) NOT NULL,
    [ORIG_CURRENCY_CODE]     NVARCHAR (3)    NOT NULL,
    [EXCH_RATE]              DECIMAL (18, 6) NOT NULL,
    [BASE_AMOUNT]            DECIMAL (18, 2) NOT NULL,
    [SOURCE_REFF_MODULE]     NVARCHAR (50)   NOT NULL,
    [SOURCE_REFF_CODE]       NVARCHAR (50)   NOT NULL,
    [SOURCE_REFF_NAME]       NVARCHAR (250)  NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL
);

