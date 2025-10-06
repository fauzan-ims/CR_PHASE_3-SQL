CREATE TABLE [dbo].[INVOICE_VAT_PAYMENT] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  NOT NULL,
    [STATUS]                NVARCHAR (10)   NOT NULL,
    [DATE]                  DATETIME        NOT NULL,
    [REMARK]                NVARCHAR (4000) NOT NULL,
    [TOTAL_PPN_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_INVOICE_VAT_PAYMENT_TOTAL_PPH_AMOUNT] DEFAULT ((0)) NOT NULL,
    [PROCESS_DATE]          DATETIME        NULL,
    [PROCESS_REFF_NO]       NVARCHAR (50)   NULL,
    [PROCESS_REFF_NAME]     NVARCHAR (250)  NULL,
    [CURRENCY_CODE]         NVARCHAR (3)    NULL,
    [TAX_BANK_NAME]         NVARCHAR (50)   NULL,
    [TAX_BANK_ACCOUNT_NAME] NVARCHAR (50)   NULL,
    [TAX_BANK_ACCOUNT_NO]   NVARCHAR (50)   NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_INVOICE_VAT_PAYMENT] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE_VAT_PAYMENT', @level2type = N'COLUMN', @level2name = N'TOTAL_PPN_AMOUNT';

