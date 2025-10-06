CREATE TABLE [dbo].[SUSPEND_REVENUE] (
    [CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]     NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]     NVARCHAR (250)  NOT NULL,
    [REVENUE_STATUS]  NVARCHAR (10)   NOT NULL,
    [REVENUE_DATE]    DATETIME        NOT NULL,
    [REVENUE_AMOUNT]  DECIMAL (18, 2) NOT NULL,
    [REVENUE_REMARKS] NVARCHAR (4000) NOT NULL,
    [CURRENCY_CODE]   NVARCHAR (3)    NULL,
    [EXCH_RATE]       DECIMAL (18, 6) CONSTRAINT [DF_SUSPEND_REVENUE_EXCH_RATE] DEFAULT ((1)) NOT NULL,
    [CRE_DATE]        DATETIME        NOT NULL,
    [CRE_BY]          NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15)   NOT NULL,
    [MOD_DATE]        DATETIME        NOT NULL,
    [MOD_BY]          NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_SUSPEND_REVENUE] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses suspend revenue tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_REVENUE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses pengakuan pendapatan dana suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_REVENUE', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses pengakuan pendapatan dana suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_REVENUE', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses suspend revenue tersebut - HOLD, menginformasikan bahwa data suspend merger tersebut belum diproses - POST, menginformasikan bahwa data suspend merger tersebut telah diposting - CANCEL, menginformasikan bahwa data suspend merger tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_REVENUE', @level2type = N'COLUMN', @level2name = N'REVENUE_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dana suspend tersebut diakui sebagai pendapatan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_REVENUE', @level2type = N'COLUMN', @level2name = N'REVENUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pada proses pengakuan pendapatan dana suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_REVENUE', @level2type = N'COLUMN', @level2name = N'REVENUE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses pengakuan pendapatan dana suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_REVENUE', @level2type = N'COLUMN', @level2name = N'REVENUE_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai revenue pada proses deposit revenue tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_REVENUE', @level2type = N'COLUMN', @level2name = N'EXCH_RATE';

