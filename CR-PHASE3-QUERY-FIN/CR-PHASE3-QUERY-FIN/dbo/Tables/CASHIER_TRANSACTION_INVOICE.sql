CREATE TABLE [dbo].[CASHIER_TRANSACTION_INVOICE] (
    [ID]                       BIGINT          IDENTITY (1, 1) NOT NULL,
    [CASHIER_TRANSACTION_CODE] NVARCHAR (50)   NOT NULL,
    [ASSET_NO]                 NVARCHAR (50)   NOT NULL,
    [CUSTOMER_NAME]            NVARCHAR (250)  NOT NULL,
    [INVOICE_NO]               NVARCHAR (50)   NOT NULL,
    [INVOICE_DATE]             DATETIME        NOT NULL,
    [INVOICE_DUE_DATE]         DATETIME        NOT NULL,
    [INVOICE_NET_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_TRANSACTION_INVOICE_INVOICE_NET_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INVOICE_BALANCE_AMOUNT]   DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_TRANSACTION_INVOICE_INVOICE_BALANCE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ALLOCATION_AMOUNT]        DECIMAL (18, 2) CONSTRAINT [DF_CASHIER_TRANSACTION_INVOICE_ALLOCATION_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_INVOICE', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode transaction kasir pada proses cashier transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_INVOICE', @level2type = N'COLUMN', @level2name = N'CASHIER_TRANSACTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : FAETP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CASHIER_TRANSACTION_INVOICE', @level2type = N'COLUMN', @level2name = N'CUSTOMER_NAME';

