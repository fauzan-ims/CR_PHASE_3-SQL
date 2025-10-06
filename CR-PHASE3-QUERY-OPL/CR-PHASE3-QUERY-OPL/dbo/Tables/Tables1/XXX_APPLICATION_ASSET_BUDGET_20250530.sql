CREATE TABLE [dbo].[XXX_APPLICATION_ASSET_BUDGET_20250530] (
    [ID]                       BIGINT          IDENTITY (1, 1) NOT NULL,
    [ASSET_NO]                 NVARCHAR (50)   NOT NULL,
    [COST_CODE]                NVARCHAR (50)   NOT NULL,
    [COST_TYPE]                NVARCHAR (10)   NOT NULL,
    [COST_AMOUNT_MONTHLY]      DECIMAL (18, 2) NOT NULL,
    [COST_AMOUNT_YEARLY]       DECIMAL (18, 2) NOT NULL,
    [BUDGET_ADJUSTMENT_AMOUNT] DECIMAL (18, 2) NOT NULL,
    [BUDGET_AMOUNT]            DECIMAL (18, 2) NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [IS_SUBJECT_TO_PURCHASE]   NVARCHAR (1)    NULL,
    [PURCHASE_CODE]            NVARCHAR (50)   NULL,
    [PURCHASE_STATUS]          NVARCHAR (250)  NULL
);

