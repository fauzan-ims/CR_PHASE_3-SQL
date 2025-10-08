CREATE TABLE [dbo].[INVOICE] (
    [INVOICE_NO]               NVARCHAR (50)   NOT NULL,
    [INVOICE_EXTERNAL_NO]      NVARCHAR (50)   NULL,
    [BRANCH_CODE]              NVARCHAR (50)   CONSTRAINT [DF_INVOICE_BRANCH_CODE] DEFAULT ('') NOT NULL,
    [BRANCH_NAME]              NVARCHAR (250)  CONSTRAINT [DF_INVOICE_BRANCH_NAME] DEFAULT ('') NOT NULL,
    [INVOICE_TYPE]             NVARCHAR (10)   NOT NULL,
    [INVOICE_DATE]             DATETIME        NOT NULL,
    [INVOICE_DUE_DATE]         DATETIME        NOT NULL,
    [INVOICE_NAME]             NVARCHAR (250)  NOT NULL,
    [INVOICE_STATUS]           NVARCHAR (10)   NOT NULL,
    [CLIENT_NO]                NVARCHAR (50)   NULL,
    [CLIENT_NAME]              NVARCHAR (250)  NOT NULL,
    [CLIENT_ADDRESS]           NVARCHAR (4000) NOT NULL,
    [CLIENT_AREA_PHONE_NO]     NVARCHAR (4)    NOT NULL,
    [CLIENT_PHONE_NO]          NVARCHAR (15)   NOT NULL,
    [CLIENT_NPWP]              NVARCHAR (50)   CONSTRAINT [DF_INVOICE_CLIENT_NPWP] DEFAULT ('') NOT NULL,
    [CURRENCY_CODE]            NVARCHAR (3)    NOT NULL,
    [TOTAL_BILLING_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_INVOICE_INSTALLMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CREDIT_BILLING_AMOUNT]    DECIMAL (18, 2) CONSTRAINT [DF_INVOICE_TOTAL_BILLING_AMOUNT1] DEFAULT ((0)) NULL,
    [TOTAL_DISCOUNT_AMOUNT]    DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_INVOICE_TOTAL_DISCOUNT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_PPN_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_INVOICE_TOTAL_AMOUNT5] DEFAULT ((0)) NOT NULL,
    [CREDIT_PPN_AMOUNT]        DECIMAL (18, 2) CONSTRAINT [DF_INVOICE_TOTAL_PPN_AMOUNT1] DEFAULT ((0)) NULL,
    [TOTAL_PPH_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_INVOICE_TOTAL_AMOUNT4] DEFAULT ((0)) NOT NULL,
    [CREDIT_PPH_AMOUNT]        DECIMAL (18, 2) CONSTRAINT [DF_INVOICE_TOTAL_PPH_AMOUNT1] DEFAULT ((0)) NULL,
    [TOTAL_AMOUNT]             DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_INVOICE_TOTAL_AMOUNT2] DEFAULT ((0)) NOT NULL,
    [STAMP_DUTY_AMOUNT]        DECIMAL (18, 2) CONSTRAINT [DF_INVOICE_STAMP_DUTY_AMOUNT] DEFAULT ((0)) NULL,
    [FAKTUR_NO]                NVARCHAR (50)   NULL,
    [GENERATE_CODE]            NVARCHAR (50)   NULL,
    [SCHEME_CODE]              NVARCHAR (50)   NULL,
    [RECEIVED_REFF_NO]         NVARCHAR (50)   NULL,
    [RECEIVED_REFF_DATE]       DATETIME        NULL,
    [DELIVER_CODE]             NVARCHAR (50)   NULL,
    [DELIVER_DATE]             DATETIME        NULL,
    [PAYMENT_PPN_CODE]         NVARCHAR (50)   NULL,
    [PAYMENT_PPN_DATE]         DATETIME        NULL,
    [PAYMENT_PPH_CODE]         NVARCHAR (50)   NULL,
    [PAYMENT_PPH_DATE]         DATETIME        NULL,
    [ADDITIONAL_INVOICE_CODE]  NVARCHAR (50)   NULL,
    [IS_JOURNAL]               NVARCHAR (1)    CONSTRAINT [DF_INVOICE_IS_JOURNAL] DEFAULT ((0)) NULL,
    [IS_RECOGNITION_JOURNAL]   NVARCHAR (1)    CONSTRAINT [DF_INVOICE_IS_JOURNAL1] DEFAULT ((0)) NULL,
    [KWITANSI_NO]              NVARCHAR (50)   NULL,
    [NEW_INVOICE_DATE]         DATETIME        NULL,
    [BILLING_TO_FAKTUR_TYPE]   NVARCHAR (3)    NULL,
    [IS_INVOICE_DEDUCT_PPH]    NVARCHAR (1)    NULL,
    [IS_RECEIPT_DEDUCT_PPH]    NVARCHAR (1)    NULL,
    [IS_JOURNAL_PPN_WAPU]      NVARCHAR (1)    CONSTRAINT [DF_INVOICE_IS_JOURNAL1_1] DEFAULT ((0)) NULL,
    [IS_JOURNAL_DATE]          DATETIME        NULL,
    [IS_JOURNAL_PPN_WAPU_DATE] DATETIME        NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [CLIENT_NITKU]             NVARCHAR (50)   NULL,
    [DPP_NILAI_LAIN]           DECIMAL (18, 2) NULL,
    [POSTING_DATE]             DATETIME        NULL,
    [CANCEL_DATE]              DATETIME        NULL,
    [POSTING_BY]               NVARCHAR (50)   NULL,
    [CANCEL_BY]                NVARCHAR (50)   NULL,
    [CLIENT_NPWP_PUSAT]        NVARCHAR (50)   NULL,
    CONSTRAINT [PK_AGREEMENT_INVOICE] PRIMARY KEY CLUSTERED ([INVOICE_NO] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IDX_INVOICE1]
    ON [dbo].[INVOICE]([INVOICE_STATUS] ASC, [CRE_BY] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_INVOICE2]
    ON [dbo].[INVOICE]([INVOICE_STATUS] ASC, [CRE_BY] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_INVOICE3]
    ON [dbo].[INVOICE]([INVOICE_STATUS] ASC, [CRE_BY] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_INVOICE_20230814]
    ON [dbo].[INVOICE]([BRANCH_CODE] ASC, [INVOICE_STATUS] ASC, [INVOICE_DATE] ASC)
    INCLUDE([BRANCH_NAME], [INVOICE_DUE_DATE]);


GO
CREATE NONCLUSTERED INDEX [IDX_INVOICE_20231009]
    ON [dbo].[INVOICE]([CRE_BY] ASC)
    INCLUDE([INVOICE_EXTERNAL_NO]);


GO
CREATE NONCLUSTERED INDEX [IDX_INVOICE_20231009_2]
    ON [dbo].[INVOICE]([INVOICE_DATE] ASC, [CLIENT_NAME] ASC, [CLIENT_NPWP] ASC, [GENERATE_CODE] ASC, [SCHEME_CODE] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_INVOICE_20231009_3]
    ON [dbo].[INVOICE]([CRE_BY] ASC)
    INCLUDE([INVOICE_EXTERNAL_NO]);


GO
CREATE NONCLUSTERED INDEX [IDX_INVOICE_20231027]
    ON [dbo].[INVOICE]([INVOICE_TYPE] ASC, [INVOICE_DUE_DATE] ASC, [INVOICE_STATUS] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_INVOICE_20240603]
    ON [dbo].[INVOICE]([INVOICE_TYPE] ASC)
    INCLUDE([IS_JOURNAL_DATE]);


GO
CREATE NONCLUSTERED INDEX [IDX_INVOICE_20241022]
    ON [dbo].[INVOICE]([INVOICE_TYPE] ASC, [INVOICE_STATUS] ASC, [INVOICE_DUE_DATE] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_INVOICE_20241126]
    ON [dbo].[INVOICE]([INVOICE_STATUS] ASC)
    INCLUDE([INVOICE_EXTERNAL_NO], [INVOICE_DUE_DATE], [INVOICE_NAME], [CLIENT_NAME], [CURRENCY_CODE], [TOTAL_PPH_AMOUNT], [FAKTUR_NO]);


GO
CREATE NONCLUSTERED INDEX [idx_xsp_rpt_agreement_amortization_invoice_status]
    ON [dbo].[INVOICE]([INVOICE_STATUS] ASC)
    INCLUDE([INVOICE_EXTERNAL_NO], [BRANCH_NAME], [INVOICE_DUE_DATE], [CLIENT_NAME]);


GO
CREATE NONCLUSTERED INDEX [IDX_INVOICE_CURRENCY_CODE_20250610]
    ON [dbo].[INVOICE]([CURRENCY_CODE] ASC)
    INCLUDE([BRANCH_NAME], [IS_JOURNAL]);


GO
CREATE NONCLUSTERED INDEX [IDX_invoice_branch_date]
    ON [dbo].[INVOICE]([BRANCH_CODE] ASC, [INVOICE_DATE] ASC)
    INCLUDE([INVOICE_NO], [INVOICE_STATUS], [CURRENCY_CODE], [TOTAL_BILLING_AMOUNT], [TOTAL_DISCOUNT_AMOUNT], [TOTAL_PPN_AMOUNT], [TOTAL_PPH_AMOUNT], [FAKTUR_NO], [CLIENT_NAME], [INVOICE_NAME], [DPP_NILAI_LAIN]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'RENTAL, OTHER', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE', @level2type = N'COLUMN', @level2name = N'INVOICE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE', @level2type = N'COLUMN', @level2name = N'CLIENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE', @level2type = N'COLUMN', @level2name = N'CLIENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE', @level2type = N'COLUMN', @level2name = N'CLIENT_ADDRESS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE', @level2type = N'COLUMN', @level2name = N'TOTAL_BILLING_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE', @level2type = N'COLUMN', @level2name = N'CREDIT_BILLING_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE', @level2type = N'COLUMN', @level2name = N'TOTAL_PPN_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE', @level2type = N'COLUMN', @level2name = N'CREDIT_PPN_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE', @level2type = N'COLUMN', @level2name = N'TOTAL_PPH_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE', @level2type = N'COLUMN', @level2name = N'CREDIT_PPH_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE', @level2type = N'COLUMN', @level2name = N'TOTAL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'UNTUK MENGCOVER CASE MUNDUR TANGGAL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE', @level2type = N'COLUMN', @level2name = N'NEW_INVOICE_DATE';


GO
CREATE NONCLUSTERED INDEX [idx_INVOICE_07102025_2]
    ON [dbo].[INVOICE]([CLIENT_NO] ASC, [INVOICE_DUE_DATE] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_INVOICE_07102025_1]
    ON [dbo].[INVOICE]([INVOICE_STATUS] ASC, [CLIENT_NO] ASC, [INVOICE_DUE_DATE] ASC)
    INCLUDE([CLIENT_NAME], [TOTAL_BILLING_AMOUNT]);


GO
CREATE NONCLUSTERED INDEX [idx_INVOICE_07102025]
    ON [dbo].[INVOICE]([INVOICE_STATUS] ASC, [INVOICE_DUE_DATE] ASC)
    INCLUDE([CLIENT_NO]);

