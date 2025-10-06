CREATE TABLE [dbo].[XXX_AGREEMENT_INVOICE_PAYMENT_30122023] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [AGREEMENT_INVOICE_CODE] NVARCHAR (50)   NOT NULL,
    [INVOICE_NO]             NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]           NVARCHAR (50)   NOT NULL,
    [ASSET_NO]               NVARCHAR (50)   NOT NULL,
    [TRANSACTION_NO]         NVARCHAR (50)   NOT NULL,
    [TRANSACTION_TYPE]       NVARCHAR (20)   NOT NULL,
    [PAYMENT_DATE]           DATETIME        NOT NULL,
    [PAYMENT_AMOUNT]         DECIMAL (18, 2) NOT NULL,
    [VOUCHER_NO]             NVARCHAR (50)   NULL,
    [DESCRIPTION]            NVARCHAR (4000) NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MF_PAYMENT_AMOUNT]      DECIMAL (18, 2) NULL
);

