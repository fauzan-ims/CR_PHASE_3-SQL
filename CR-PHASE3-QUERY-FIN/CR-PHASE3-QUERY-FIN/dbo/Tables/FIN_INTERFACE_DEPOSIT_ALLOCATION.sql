CREATE TABLE [dbo].[FIN_INTERFACE_DEPOSIT_ALLOCATION] (
    [ID]             BIGINT          IDENTITY (1, 1) NOT NULL,
    [CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]    NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]    NVARCHAR (250)  NOT NULL,
    [STATUS]         NVARCHAR (10)   NOT NULL,
    [TRX_DATE]       DATETIME        NOT NULL,
    [ORIG_AMOUNT]    DECIMAL (18, 2) NOT NULL,
    [CURRENCY_CODE]  NVARCHAR (3)    NOT NULL,
    [EXCH_RATE]      DECIMAL (18, 6) NOT NULL,
    [BASE_AMOUNT]    DECIMAL (18, 2) NOT NULL,
    [REMARK]         NVARCHAR (4000) NOT NULL,
    [AGREEMENT_NO]   NVARCHAR (50)   NOT NULL,
    [DEPOSIT_CODE]   NVARCHAR (50)   NOT NULL,
    [DEPOSIT_TYPE]   NVARCHAR (15)   NOT NULL,
    [DEPOSIT_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_FIN_INTERFACE_ALLOCATION_DEPOSIT_DEPOSIT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [JOB_STATUS]     NVARCHAR (20)   CONSTRAINT [DF_FIN_INTERFACE_DEPOSIT_ALLOCATION_JOB_STATUS] DEFAULT (N'HOLD') NULL,
    [FAILED_REMARK]  NVARCHAR (4000) NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_FIN_INTERFACE_ALLOCATION_DEPOSIT] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi alokasi pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'TRX_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai alokasi original pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'BASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'REMARK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode deposit pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'DEPOSIT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada proses alokasi deposit tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION', @level2type = N'COLUMN', @level2name = N'DEPOSIT_AMOUNT';

