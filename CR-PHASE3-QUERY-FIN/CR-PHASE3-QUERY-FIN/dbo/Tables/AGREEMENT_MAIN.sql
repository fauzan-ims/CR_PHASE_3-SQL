CREATE TABLE [dbo].[AGREEMENT_MAIN] (
    [AGREEMENT_NO]             NVARCHAR (50)   NOT NULL,
    [AGREEMENT_EXTERNAL_NO]    NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]              NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]              NVARCHAR (250)  NOT NULL,
    [AGREEMENT_DATE]           DATETIME        NOT NULL,
    [AGREEMENT_STATUS]         NVARCHAR (10)   NOT NULL,
    [AGREEMENT_SUB_STATUS]     NVARCHAR (20)   CONSTRAINT [DF_AGREEMENT_MAIN_AGREEMENT_SUB_STATUS] DEFAULT ('') NOT NULL,
    [CURRENCY_CODE]            NVARCHAR (3)    NOT NULL,
    [FACILITY_CODE]            NVARCHAR (50)   NULL,
    [FACILITY_NAME]            NVARCHAR (250)  NULL,
    [PURPOSE_LOAN_CODE]        NVARCHAR (50)   NULL,
    [PURPOSE_LOAN_NAME]        NVARCHAR (250)  NULL,
    [PURPOSE_LOAN_DETAIL_CODE] NVARCHAR (50)   NULL,
    [PURPOSE_LOAN_DETAIL_NAME] NVARCHAR (250)  NULL,
    [TERMINATION_DATE]         DATETIME        NULL,
    [TERMINATION_STATUS]       NVARCHAR (20)   NULL,
    [CLIENT_CODE]              NVARCHAR (50)   NOT NULL,
    [CLIENT_NAME]              NVARCHAR (250)  NOT NULL,
    [ASSET_DESCRIPTION]        NVARCHAR (250)  NOT NULL,
    [COLLATERAL_DESCRIPTION]   NVARCHAR (250)  NOT NULL,
    [LAST_PAID_INSTALLMENT_NO] INT             CONSTRAINT [DF_AGREEMENT_MAIN_OVERDUE_DAYS1] DEFAULT ((0)) NOT NULL,
    [OVERDUE_PERIOD]           INT             CONSTRAINT [DF_AGREEMENT_MAIN_OVERDUE_PERIOD] DEFAULT ((0)) NOT NULL,
    [IS_WO]                    NVARCHAR (1)    CONSTRAINT [DF_AGREEMENT_MAIN_IS_REMEDIAL1] DEFAULT ((0)) NOT NULL,
    [INSTALLMENT_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_MAIN_INSTALLMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [NEXT_DUE_DATE]            DATETIME        NULL,
    [INSTALLMENT_DUE_DATE]     DATETIME        NULL,
    [OVERDUE_DAYS]             INT             CONSTRAINT [DF_AGREEMENT_MAIN_COLLECTION_GROUP1] DEFAULT ((0)) NOT NULL,
    [FACTORING_TYPE]           NVARCHAR (10)   NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_AGREEMENT_MAIN] PRIMARY KEY CLUSTERED ([AGREEMENT_NO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor external kontrak pembiayaan pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_EXTERNAL_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kontrak pembiayaan pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status kontrak pembiayaan pada data agreement main tersebut - GO LIVE, menginformasikan bahwa kontrak pembiayaan tersebut berstatus go live - TERMINATE, menginformasikan bahwa data kontrak pembiayaan tersebut sudah dilakukan proses terminasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status kontrak pembiayaan pada data agreement main tersebut - GO LIVE, menginformasikan bahwa kontrak pembiayaan tersebut berstatus go live - TERMINATE, menginformasikan bahwa data kontrak pembiayaan tersebut sudah dilakukan proses terminasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_SUB_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status kontrak pembiayaan pada data agreement main tersebut - GO LIVE, menginformasikan bahwa kontrak pembiayaan tersebut berstatus go live - TERMINATE, menginformasikan bahwa data kontrak pembiayaan tersebut sudah dilakukan proses terminasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode facility pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'FACILITY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama facility pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'FACILITY_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode tujuan pembiayaan pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'PURPOSE_LOAN_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama tujuan pembiayaan pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'PURPOSE_LOAN_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode detail tujuan pembiayaan pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'PURPOSE_LOAN_DETAIL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama detail tujuan pembiayaan pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'PURPOSE_LOAN_DETAIL_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kontrak pembiayaan tersebut dilakukan proses terminate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'TERMINATION_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status terminasi pada data agreement main tersebut - NORMAL, menginformasikan bahwa data kontrak pembiayaan tersebut lunas dengan normal - ET, menginformasikan bahwa data kontrak pembiayaan tersebut dilakukan pelunasan dipercepat - SOLD, menginformasikan bahwa data kontrak pembiayaan tersebut dilunasi dengan cara dijual - WO, menginformasikan bahwa data kontrak pembiayaan tersebut dilunasi dengan cara write off', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'TERMINATION_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama client pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'CLIENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama client pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'CLIENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi asset pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'ASSET_DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi collateral pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'COLLATERAL_DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran terakhir yang dilakukan proses pembayaran pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'LAST_PAID_INSTALLMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah overdur period pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'OVERDUE_PERIOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah kontrak pembiayaan tersebut dilakukan proses write off?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'IS_WO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai angsuran pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal jatuh tempo angsuran pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_DUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah overdue days pada data agreement main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'OVERDUE_DAYS';

