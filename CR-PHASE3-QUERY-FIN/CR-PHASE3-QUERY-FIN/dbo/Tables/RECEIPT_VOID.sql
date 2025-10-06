CREATE TABLE [dbo].[RECEIPT_VOID] (
    [CODE]             NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]      NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]      NVARCHAR (250)  NOT NULL,
    [VOID_STATUS]      NVARCHAR (10)   NOT NULL,
    [VOID_DATE]        DATETIME        NOT NULL,
    [VOID_REASON_CODE] NVARCHAR (50)   NOT NULL,
    [VOID_REMARKS]     NVARCHAR (4000) NOT NULL,
    [CRE_DATE]         DATETIME        NOT NULL,
    [CRE_BY]           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]         DATETIME        NOT NULL,
    [MOD_BY]           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_RECEIPT_VOID] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses receipt void tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_VOID', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses receipt void tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_VOID', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses receipt void tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_VOID', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses receipt void tersebut - HOLD, menginformasikan bahwa receipt void tersebut belum diproses - POST, menginformasikan bahwa receipt void tersebut telah diposting - CANCEL, menginformasikan bahwa receipt void tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_VOID', @level2type = N'COLUMN', @level2name = N'VOID_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kwitansi tersebut dilakukan proses void tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_VOID', @level2type = N'COLUMN', @level2name = N'VOID_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode alasan kwitansi tersebut dilakukan proses void', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_VOID', @level2type = N'COLUMN', @level2name = N'VOID_REASON_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses receipt void tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_VOID', @level2type = N'COLUMN', @level2name = N'VOID_REMARKS';

