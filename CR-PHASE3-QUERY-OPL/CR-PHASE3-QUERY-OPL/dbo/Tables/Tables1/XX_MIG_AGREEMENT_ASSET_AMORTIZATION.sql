CREATE TABLE [dbo].[XX_MIG_AGREEMENT_ASSET_AMORTIZATION] (
    [AGREEMENT_NO]        NVARCHAR (50)   NULL,
    [BILLING_NO]          BIGINT          NULL,
    [ASSET_NO]            NVARCHAR (50)   NULL,
    [DUE_DATE]            DATETIME        NULL,
    [BILLING_DATE]        DATETIME        NULL,
    [BILLING_AMOUNT]      DECIMAL (18, 2) NULL,
    [INVOICE_NO]          NVARCHAR (50)   NULL,
    [GENERATE_CODE]       NVARCHAR (50)   NULL,
    [HOLD_BILLING_STATUS] NVARCHAR (50)   NULL,
    [PERIOD]              INT             NULL
);

