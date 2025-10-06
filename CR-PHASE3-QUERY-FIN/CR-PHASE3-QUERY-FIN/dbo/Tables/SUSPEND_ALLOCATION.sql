CREATE TABLE [dbo].[SUSPEND_ALLOCATION] (
    [CODE]                     NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]              NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]              NVARCHAR (250)  NOT NULL,
    [ALLOCATION_STATUS]        NVARCHAR (10)   NOT NULL,
    [ALLOCATION_TRX_DATE]      DATETIME        NOT NULL,
    [ALLOCATION_VALUE_DATE]    DATETIME        NOT NULL,
    [ALLOCATION_ORIG_AMOUNT]   DECIMAL (18, 2) NOT NULL,
    [ALLOCATION_CURRENCY_CODE] NVARCHAR (3)    NOT NULL,
    [ALLOCATION_EXCH_RATE]     DECIMAL (18, 6) NOT NULL,
    [ALLOCATION_BASE_AMOUNT]   DECIMAL (18, 2) NOT NULL,
    [ALLOCATIONT_REMARKS]      NVARCHAR (4000) NOT NULL,
    [SUSPEND_CODE]             NVARCHAR (50)   NULL,
    [SUSPEND_GL_LINK_CODE]     NVARCHAR (50)   NOT NULL,
    [SUSPEND_AMOUNT]           DECIMAL (18, 2) NOT NULL,
    [AGREEMENT_NO]             NVARCHAR (50)   CONSTRAINT [DF_SUSPEND_ALLOCATION_AGREEMENT_NO] DEFAULT ((0)) NULL,
    [IS_RECEIVED_REQUEST]      NVARCHAR (1)    CONSTRAINT [DF_SUSPEND_ALLOCATION_IS_RECEIVED_REQUEST] DEFAULT ((0)) NOT NULL,
    [VOUCHER_NO]               NVARCHAR (50)   NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_SUSPEND_ALLOCATION] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_SUSPEND_ALLOCATION_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO]),
    CONSTRAINT [FK_SUSPEND_ALLOCATION_SUSPEND_MAIN] FOREIGN KEY ([SUSPEND_CODE]) REFERENCES [dbo].[SUSPEND_MAIN] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses alokasi suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses alokasi suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses alokasi suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses alokasi suspend tersebut - HOLD, menginformasikan bahwa data alokasi suspend tersebut belum diproses - POST, menginformasikan bahwa data alokasi suspend tersebut sudah diposting - CANCEL, menginformasikan bahwa data alokasi suspend tersebut telah dibatalkan - REVERSE, menginformasikan bahwa data alokasi suspend tersebut telah dilakukan proses reversal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATION_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi alokasi suspend tersebut dilakukan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATION_TRX_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal alokasi suspend tersebut diakui', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATION_VALUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original pada proses alokasi suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATION_ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses alokasi suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATION_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses alokasi suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATION_EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada proses alokasi suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATION_BASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses alokasi suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ALLOCATIONT_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode suspend pada proses alokasi suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'SUSPEND_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai suspend pada proses alokasi suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'SUSPEND_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada proses alokasi suspend tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data suspend allocation tersebut berasal dari cashier received request?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_ALLOCATION', @level2type = N'COLUMN', @level2name = N'IS_RECEIVED_REQUEST';

