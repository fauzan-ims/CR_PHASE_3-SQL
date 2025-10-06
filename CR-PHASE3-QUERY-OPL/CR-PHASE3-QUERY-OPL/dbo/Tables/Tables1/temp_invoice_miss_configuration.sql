CREATE TABLE [dbo].[temp_invoice_miss_configuration] (
    [AGREEMENT_NO]           NVARCHAR (50) NULL,
    [INVOICE_NO]             NVARCHAR (50) NOT NULL,
    [BILLING_TO_FAKTUR_TYPE] NVARCHAR (3)  NULL,
    [IS_INVOICE_DEDUCT_PPH]  NVARCHAR (1)  NULL
);

