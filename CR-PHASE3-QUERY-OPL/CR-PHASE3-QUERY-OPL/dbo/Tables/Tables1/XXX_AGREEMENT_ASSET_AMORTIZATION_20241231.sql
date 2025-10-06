CREATE TABLE [dbo].[XXX_AGREEMENT_ASSET_AMORTIZATION_20241231] (
    [AGREEMENT_NO]        NVARCHAR (50)   NOT NULL,
    [BILLING_NO]          INT             NOT NULL,
    [ASSET_NO]            NVARCHAR (50)   NOT NULL,
    [DUE_DATE]            DATETIME        NOT NULL,
    [BILLING_DATE]        DATETIME        NOT NULL,
    [BILLING_AMOUNT]      DECIMAL (18, 2) NOT NULL,
    [DESCRIPTION]         NVARCHAR (4000) NOT NULL,
    [INVOICE_NO]          NVARCHAR (50)   NULL,
    [GENERATE_CODE]       NVARCHAR (50)   NULL,
    [HOLD_BILLING_STATUS] NVARCHAR (10)   NULL,
    [HOLD_DATE]           DATETIME        NULL,
    [REFF_CODE]           NVARCHAR (50)   NULL,
    [REFF_REMARK]         NVARCHAR (4000) NULL,
    [REFF_DATE]           DATETIME        NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL
);

