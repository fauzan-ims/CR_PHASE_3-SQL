CREATE TABLE [dbo].[MTN_INVOICE_MIGRASI_ADDITIONAL] (
    [INVOICE_EXTERNAL_NO] NVARCHAR (50)   NULL,
    [AGREEMENT_NO]        NVARCHAR (50)   NULL,
    [CUSTOMER]            NVARCHAR (250)  NULL,
    [NOPOL]               NVARCHAR (250)  NULL,
    [ASSET_NO]            NVARCHAR (250)  NULL,
    [BILLING_NO]          NVARCHAR (50)   NULL,
    [FAKTUR_NO]           NVARCHAR (50)   NULL,
    [TYPE]                NVARCHAR (50)   NULL,
    [DESCRIPTION]         NVARCHAR (250)  NULL,
    [BILLING_AMOUNT]      DECIMAL (18, 2) NULL,
    [PPN_PCT]             DECIMAL (18, 2) NULL,
    [PPN_AMOUNT]          DECIMAL (18, 2) NULL,
    [PPH_PCT]             DECIMAL (18, 2) NULL,
    [PPH_AMOUNT]          DECIMAL (18, 2) NULL,
    [TOTAL_AMOUNT]        DECIMAL (18, 2) NULL
);

