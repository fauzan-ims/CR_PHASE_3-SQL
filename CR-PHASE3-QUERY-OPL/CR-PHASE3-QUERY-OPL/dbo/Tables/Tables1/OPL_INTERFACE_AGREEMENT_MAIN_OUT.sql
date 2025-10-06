CREATE TABLE [dbo].[OPL_INTERFACE_AGREEMENT_MAIN_OUT] (
    [ID]                             BIGINT          IDENTITY (1, 1) NOT NULL,
    [AGREEMENT_NO]                   NVARCHAR (50)   NOT NULL,
    [AGREEMENT_EXTERNAL_NO]          NVARCHAR (50)   NULL,
    [APPLICATION_NO]                 NVARCHAR (50)   NULL,
    [AGREEMENT_DATE]                 DATETIME        NULL,
    [AGREEMENT_STATUS]               NVARCHAR (10)   NULL,
    [AGREEMENT_SUB_STATUS]           NVARCHAR (20)   CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_MAIN_OUT_AGREEMENT_SUB_STATUS] DEFAULT ('') NULL,
    [COLLATERAL_DESCRIPTION]         NVARCHAR (250)  NULL,
    [ASSET_DESCRIPTION]              NVARCHAR (250)  NULL,
    [TERMINATION_DATE]               DATETIME        NULL,
    [TERMINATION_STATUS]             NVARCHAR (20)   NULL,
    [BRANCH_CODE]                    NVARCHAR (50)   NULL,
    [BRANCH_NAME]                    NVARCHAR (250)  NULL,
    [INITIAL_BRANCH_CODE]            NVARCHAR (50)   NULL,
    [INITIAL_BRANCH_NAME]            NVARCHAR (250)  NULL,
    [FACILITY_CODE]                  NVARCHAR (50)   NULL,
    [FACILITY_NAME]                  NVARCHAR (250)  NULL,
    [PURPOSE_LOAN_CODE]              NVARCHAR (50)   NULL,
    [PURPOSE_LOAN_NAME]              NVARCHAR (250)  NULL,
    [PURPOSE_LOAN_DETAIL_CODE]       NVARCHAR (50)   NULL,
    [PURPOSE_LOAN_DETAIL_NAME]       NVARCHAR (250)  NULL,
    [CURRENCY_CODE]                  NVARCHAR (3)    NULL,
    [CLIENT_TYPE]                    NVARCHAR (10)   NULL,
    [CLIENT_NO]                      NVARCHAR (50)   NULL,
    [CLIENT_NAME]                    NVARCHAR (250)  NULL,
    [PAYMENT_WITH_CODE]              NVARCHAR (50)   NULL,
    [PAYMENT_WITH_NAME]              NVARCHAR (250)  CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_MAIN_OUT_PAYMENT_WITH_NAME] DEFAULT ('') NULL,
    [LAST_INSTALLMENT_DUE_DATE]      DATETIME        NULL,
    [LAST_PAID_PERIOD]               INT             CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_MAIN_OUT_LAST_PAID_PERIOD] DEFAULT ((0)) NULL,
    [OVERDUE_PERIOD]                 INT             CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_MAIN_OUT_OVERDUE_PERIOD] DEFAULT ((0)) NULL,
    [OVERDUE_DAYS]                   INT             CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_MAIN_OUT_OVERDUE_DAYS] DEFAULT ((0)) NULL,
    [OVERDUE_INSTALLMENT_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_MAIN_OUT_OVERDUE_INSTALLMENT_AMOUNT] DEFAULT ((0)) NULL,
    [OVERDUE_PENALTY_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_MAIN_OUT_OVERDUE_PENALTY_AMOUNT] DEFAULT ((0)) NULL,
    [OUTSTANDING_INSTALLMENT_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_MAIN_OUT_OUTSTANDING_INSTALLMENT_AMOUNT] DEFAULT ((0)) NULL,
    [OUTSTANDING_DEPOSIT_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_OPL_INTERFACE_AGREEMENT_MAIN_OUT_OUTSTANDING_DEPOSIT_AMOUNT] DEFAULT ((0)) NULL,
    [FACTORING_TYPE]                 NVARCHAR (10)   NULL,
    [CLIENT_GENDER]                  NVARCHAR (1)    NULL,
    [CLIENT_DATE_OF_BIRTH]           DATETIME        NULL,
    [IS_SYARIAH]                     NVARCHAR (1)    NULL,
    [REFF_1]                         NVARCHAR (50)   NULL,
    [REFF_2]                         NVARCHAR (50)   NULL,
    [REFF_3]                         NVARCHAR (50)   NULL,
    [REFF_4]                         NVARCHAR (50)   NULL,
    [REFF_5]                         NVARCHAR (50)   NULL,
    [REFF_6]                         NVARCHAR (50)   NULL,
    [REFF_7]                         NVARCHAR (50)   NULL,
    [REFF_8]                         NVARCHAR (50)   NULL,
    [REFF_9]                         NVARCHAR (50)   NULL,
    [REFF_10]                        NVARCHAR (50)   NULL,
    [CRE_DATE]                       DATETIME        NOT NULL,
    [CRE_BY]                         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                       DATETIME        NOT NULL,
    [MOD_BY]                         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_OPL_INTERFACE_AGREEMENT_MAIN_OUT] PRIMARY KEY CLUSTERED ([AGREEMENT_NO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada data agreement main tersebut - GO LIVE, menginformasikan bahwa kontrak pembiayaan tersebut sedang berstatus Go Live - TERMINATE, menginformasikan bahwa data kontrak pembiayaan tersebut sudah dilakukan proses terminate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_MAIN_OUT', @level2type = N'COLUMN', @level2name = N'AGREEMENT_SUB_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode metode pembayaran yang digunakan pada kontrak pembiayaan tersebut - TRANSFER, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cara transfer - PDC, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cek atau pdc - CASH, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cara uang cash di kasir cabang - PAYMENTPOINT, menginformasikan bahwa kontrak pembiayaan tersebut dibayar pada payment point - AUTODEBIT, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cara autodebit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_MAIN_OUT', @level2type = N'COLUMN', @level2name = N'PAYMENT_WITH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Metode pembayaran yang digunakan pada kontrak pembiayaan tersebut - TRANSFER, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cara transfer - PDC, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cek atau pdc - CASH, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cara uang cash di kasir cabang - PAYMENTPOINT, menginformasikan bahwa kontrak pembiayaan tersebut dibayar pada payment point - AUTODEBIT, menginformasikan bahwa kontrak pembiayaan tersebut dibayar dengan cara autodebit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_MAIN_OUT', @level2type = N'COLUMN', @level2name = N'PAYMENT_WITH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah periode terlambat pada kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_MAIN_OUT', @level2type = N'COLUMN', @level2name = N'OVERDUE_PERIOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah hari keterlambatan pada kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_MAIN_OUT', @level2type = N'COLUMN', @level2name = N'OVERDUE_DAYS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai keterlambatan angsuran pada kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_MAIN_OUT', @level2type = N'COLUMN', @level2name = N'OVERDUE_INSTALLMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nilai pinalti keterlambatan pembayaran pada kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_MAIN_OUT', @level2type = N'COLUMN', @level2name = N'OVERDUE_PENALTY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai sisa angsuran yang belum dibayar pada kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_MAIN_OUT', @level2type = N'COLUMN', @level2name = N'OUTSTANDING_INSTALLMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai outstanding deposit pada kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_AGREEMENT_MAIN_OUT', @level2type = N'COLUMN', @level2name = N'OUTSTANDING_DEPOSIT_AMOUNT';

