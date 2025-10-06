CREATE TABLE [dbo].[XXX_SUSPEND_MAIN_06112023] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  NOT NULL,
    [SUSPEND_CURRENCY_CODE] NVARCHAR (3)    NOT NULL,
    [SUSPEND_DATE]          DATETIME        NOT NULL,
    [SUSPEND_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [SUSPEND_REMARKS]       NVARCHAR (4000) NOT NULL,
    [USED_AMOUNT]           DECIMAL (18, 2) NOT NULL,
    [REMAINING_AMOUNT]      DECIMAL (18, 2) NOT NULL,
    [REFF_NAME]             NVARCHAR (250)  NULL,
    [REFF_NO]               NVARCHAR (50)   NULL,
    [TRANSACTION_CODE]      NVARCHAR (50)   NULL,
    [TRANSACTION_NAME]      NVARCHAR (250)  NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL
);

