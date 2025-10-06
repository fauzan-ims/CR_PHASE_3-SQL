CREATE TABLE [dbo].[DOCUMENT_STORAGE] (
    [CODE]           NVARCHAR (50)  NOT NULL,
    [BRANCH_CODE]    NVARCHAR (50)  NOT NULL,
    [BRANCH_NAME]    NVARCHAR (250) NOT NULL,
    [STORAGE_STATUS] NVARCHAR (20)  NOT NULL,
    [STORAGE_DATE]   DATETIME       NOT NULL,
    [STORAGE_TYPE]   NVARCHAR (20)  NOT NULL,
    [LOCKER_CODE]    NVARCHAR (50)  NULL,
    [DRAWER_CODE]    NVARCHAR (50)  NULL,
    [ROW_CODE]       NVARCHAR (50)  NULL,
    [REMARK]         NVARCHAR (250) NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_DOCUMENT_STORE_HEADER] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_DOCUMENT_STORAGE_MASTER_DRAWER] FOREIGN KEY ([DRAWER_CODE]) REFERENCES [dbo].[MASTER_DRAWER] ([CODE]),
    CONSTRAINT [FK_DOCUMENT_STORAGE_MASTER_LOCKER] FOREIGN KEY ([LOCKER_CODE]) REFERENCES [dbo].[MASTER_LOCKER] ([CODE]),
    CONSTRAINT [FK_DOCUMENT_STORAGE_MASTER_ROW] FOREIGN KEY ([ROW_CODE]) REFERENCES [dbo].[MASTER_ROW] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses document storage tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_STORAGE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses document storage tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_STORAGE', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses document storage tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_STORAGE', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses document storage tersebut - HOLD, menginformasikan bahwa data pada proses document storage tersebut belum diproses - POST, menginformasikan bahwa data pada proses document storage tersebut sudah dilakukan proses posting - CANCEL, menginformasikan bahwa data pada proses document storage tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_STORAGE', @level2type = N'COLUMN', @level2name = N'STORAGE_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukan proses penyimpanan pada proses document storage tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_STORAGE', @level2type = N'COLUMN', @level2name = N'STORAGE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe storage pada proses document storage tersebut - STORE , menginformasikan bahwa dokumen tersebut dilakukan proses penyimpanan - RETRIVE, menginformasikan bahwa dokumen tersebut dikeluarkan dari tempat penyimpanan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_STORAGE', @level2type = N'COLUMN', @level2name = N'STORAGE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode loker pada proses document storage tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_STORAGE', @level2type = N'COLUMN', @level2name = N'LOCKER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode rak pada proses document storage tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_STORAGE', @level2type = N'COLUMN', @level2name = N'DRAWER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode baris pada proses document storage tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_STORAGE', @level2type = N'COLUMN', @level2name = N'ROW_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses document storage tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_STORAGE', @level2type = N'COLUMN', @level2name = N'REMARK';

