CREATE TABLE [dbo].[RECEIPT_MAIN] (
    [CODE]             NVARCHAR (50)  NOT NULL,
    [BRANCH_CODE]      NVARCHAR (50)  NOT NULL,
    [BRANCH_NAME]      NVARCHAR (250) NOT NULL,
    [RECEIPT_STATUS]   NVARCHAR (10)  NOT NULL,
    [RECEIPT_USE_DATE] DATETIME       NULL,
    [RECEIPT_NO]       NVARCHAR (150) NOT NULL,
    [CASHIER_CODE]     NVARCHAR (50)  NULL,
    [MAX_PRINT_COUNT]  INT            CONSTRAINT [DF_KWITANSI_MAIN_MAX_PRINT] DEFAULT ((0)) NOT NULL,
    [PRINT_COUNT]      INT            CONSTRAINT [DF_KWITANSI_MAIN_PRINT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]         DATETIME       NOT NULL,
    [CRE_BY]           NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    [MOD_DATE]         DATETIME       NOT NULL,
    [MOD_BY]           NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_RECEIPT_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses receipt main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses receipt main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses receipt main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kwitansi tersebut digunakan pada proses receipt main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_MAIN', @level2type = N'COLUMN', @level2name = N'RECEIPT_USE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kwitansi pada proses receipt main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_MAIN', @level2type = N'COLUMN', @level2name = N'RECEIPT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kasir pada proses receipt main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_MAIN', @level2type = N'COLUMN', @level2name = N'CASHIER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas maksimal dilakukan proses print kwitansi pada proses receipt main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_MAIN', @level2type = N'COLUMN', @level2name = N'MAX_PRINT_COUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Berapa kali kwitansi tersebut sudah dilakukan proses print pada proses receipt main tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_MAIN', @level2type = N'COLUMN', @level2name = N'PRINT_COUNT';

