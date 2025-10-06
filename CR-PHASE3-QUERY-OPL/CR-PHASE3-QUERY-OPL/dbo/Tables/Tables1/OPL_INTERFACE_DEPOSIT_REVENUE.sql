CREATE TABLE [dbo].[OPL_INTERFACE_DEPOSIT_REVENUE] (
    [ID]              BIGINT          IDENTITY (1, 1) NOT NULL,
    [CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]     NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]     NVARCHAR (250)  NOT NULL,
    [REVENUE_STATUS]  NVARCHAR (10)   NOT NULL,
    [REVENUE_DATE]    DATETIME        NOT NULL,
    [REVENUE_AMOUNT]  DECIMAL (18, 2) NOT NULL,
    [REVENUE_REMARKS] NVARCHAR (4000) NOT NULL,
    [AGREEMENT_NO]    NVARCHAR (50)   NOT NULL,
    [CURRENCY_CODE]   NVARCHAR (3)    NULL,
    [EXCH_RATE]       DECIMAL (18, 6) CONSTRAINT [DF_OPL_INTERFACE_DEPOSIT_REVENUE_EXCH_RATE] DEFAULT ((1)) NOT NULL,
    [CRE_DATE]        DATETIME        NOT NULL,
    [CRE_BY]          NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15)   NOT NULL,
    [MOD_DATE]        DATETIME        NOT NULL,
    [MOD_BY]          NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_OPL_INTERFACE_DEPOSIT_REVENUE] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses deposit revenue tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_DEPOSIT_REVENUE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses deposit revenue tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_DEPOSIT_REVENUE', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses deposit revenue tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_DEPOSIT_REVENUE', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses deposit revenue tersebut - HOLD, menginformasikan bahwa data deposit revenue tersebut belum diproses - POST, menginformasikan bahwa data deposit revenue tersebut sudah dilakukan proses posting - CANCEL, menginformasikan bahwa data deposit revenue tersebut telah dibatalkan - APPROVE, menginformasikan bahwa data deposit revenue tersebut telah disetujui - REJECT, menginformasikan bahwa data deposit revenue tersebut telah ditolak - RETURN, menginformasikan bahwa data deposit revenue tersebut dikembalikan ke user maker', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_DEPOSIT_REVENUE', @level2type = N'COLUMN', @level2name = N'REVENUE_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal deposit revenue tersebut dilakukan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_DEPOSIT_REVENUE', @level2type = N'COLUMN', @level2name = N'REVENUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai revenue pada proses deposit revenue tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_DEPOSIT_REVENUE', @level2type = N'COLUMN', @level2name = N'REVENUE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses deposit revenue tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_DEPOSIT_REVENUE', @level2type = N'COLUMN', @level2name = N'REVENUE_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada proses deposit revenue tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_DEPOSIT_REVENUE', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai revenue pada proses deposit revenue tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_DEPOSIT_REVENUE', @level2type = N'COLUMN', @level2name = N'EXCH_RATE';

