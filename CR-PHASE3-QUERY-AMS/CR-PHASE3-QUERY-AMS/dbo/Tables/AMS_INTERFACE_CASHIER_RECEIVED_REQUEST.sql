CREATE TABLE [dbo].[AMS_INTERFACE_CASHIER_RECEIVED_REQUEST] (
    [ID]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  NOT NULL,
    [REQUEST_STATUS]        NVARCHAR (10)   NOT NULL,
    [REQUEST_CURRENCY_CODE] NVARCHAR (3)    NOT NULL,
    [REQUEST_DATE]          DATETIME        NOT NULL,
    [REQUEST_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [REQUEST_REMARKS]       NVARCHAR (4000) NOT NULL,
    [FA_CODE]               NVARCHAR (50)   NULL,
    [PDC_CODE]              NVARCHAR (50)   NULL,
    [PDC_NO]                NVARCHAR (50)   NULL,
    [DOC_REF_CODE]          NVARCHAR (50)   NOT NULL,
    [DOC_REF_NAME]          NVARCHAR (250)  NOT NULL,
    [PROCESS_DATE]          DATETIME        NULL,
    [PROCESS_REFF_NO]       NVARCHAR (50)   NULL,
    [PROCESS_REFF_NAME]     NVARCHAR (250)  NULL,
    [SETTLE_DATE]           DATETIME        NULL,
    [JOB_STATUS]            NVARCHAR (10)   CONSTRAINT [DF_AMS_INTERFACE_CASHIER_RECEIVED_REQUEST_JOB_STATUS] DEFAULT (N'HOLD') NOT NULL,
    [FAILED_REMARKS]        NVARCHAR (4000) NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NULL,
    CONSTRAINT [PK_AMS_INTERFACE_CASHIER_RECEIVED_REQUEST] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status request pada proses cashier received request tersebut - HOLD, menginformasikan bahwa data cashier received request tersebut belum di proses - PAID, menginformasikan bahwa data cashier received request tersebut telah dilakukan proses pembayaran', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada data cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukan proses request pada data cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pada data cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada data cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor agreement pada data cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'FA_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode PDC pada data cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'PDC_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor PDC pada data cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'PDC_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode referensi dokumen pada data cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'DOC_REF_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama referensi dokumen pada data cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'DOC_REF_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal data cashier received request tersebut di proses', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'PROCESS_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor referensi pada proses cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'PROCESS_REFF_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama referensi pada proses cashier received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'PROCESS_REFF_NAME';

