CREATE TABLE [dbo].[AMS_INTERFACE_DOCUMENT_REQUEST] (
    [ID]                         BIGINT          IDENTITY (1, 1) NOT NULL,
    [CODE]                       NVARCHAR (50)   NOT NULL,
    [REQUEST_BRANCH_CODE]        NVARCHAR (50)   NOT NULL,
    [REQUEST_BRANCH_NAME]        NVARCHAR (250)  NOT NULL,
    [REQUEST_TYPE]               NVARCHAR (20)   CONSTRAINT [DF_AMS_INTERFACE_DOCUMENT_REQUEST_REQUEST_TYPE] DEFAULT (N'OUT LOCKER') NOT NULL,
    [REQUEST_LOCATION]           NVARCHAR (20)   CONSTRAINT [DF_AMS_INTERFACE_DOCUMENT_REQUEST_REQUEST_LOCATION] DEFAULT (N'OUT LOCKER') NOT NULL,
    [REQUEST_FROM]               NVARCHAR (50)   CONSTRAINT [DF_AMS_INTERFACE_DOCUMENT_REQUEST_REQUEST_FROM] DEFAULT (N'OUT LOCKER') NOT NULL,
    [REQUEST_TO]                 NVARCHAR (50)   CONSTRAINT [DF_AMS_INTERFACE_DOCUMENT_REQUEST_REQUEST_TO] DEFAULT (N'OUT LOCKER') NOT NULL,
    [REQUEST_TO_BRANCH_CODE]     NVARCHAR (50)   NULL,
    [REQUEST_TO_BRANCH_NAME]     NVARCHAR (250)  NULL,
    [REQUEST_TO_AGREEMENT_NO]    NVARCHAR (50)   NULL,
    [REQUEST_TO_CLIENT_NAME]     NVARCHAR (250)  NULL,
    [REQUEST_FROM_DEPT_CODE]     NVARCHAR (50)   NULL,
    [REQUEST_FROM_DEPT_NAME]     NVARCHAR (250)  NULL,
    [REQUEST_TO_DEPT_CODE]       NVARCHAR (50)   NULL,
    [REQUEST_TO_DEPT_NAME]       NVARCHAR (250)  NOT NULL,
    [REQUEST_TO_THIRDPARTY_TYPE] NVARCHAR (250)  NULL,
    [AGREEMENT_NO]               NVARCHAR (50)   NULL,
    [COLLATERAL_NO]              NVARCHAR (50)   NULL,
    [ASSET_NO]                   NVARCHAR (50)   NULL,
    [REQUEST_BY]                 NVARCHAR (250)  CONSTRAINT [DF_AMS_INTERFACE_DOCUMENT_REQUEST_REQUEST_BY] DEFAULT (N'OUT LOCKER') NOT NULL,
    [REQUEST_STATUS]             NVARCHAR (50)   CONSTRAINT [DF_AMS_INTERFACE_DOCUMENT_REQUEST_REQUEST_STATUS] DEFAULT (N'OUT LOCKER') NOT NULL,
    [REQUEST_DATE]               DATETIME        NOT NULL,
    [REMARKS]                    NVARCHAR (4000) NOT NULL,
    [DOCUMENT_CODE]              NVARCHAR (50)   CONSTRAINT [DF_AMS_INTERFACE_DOCUMENT_REQUEST_DOCUMENT_CODE] DEFAULT ('') NULL,
    [PROCESS_DATE]               DATETIME        NULL,
    [PROCESS_REFF_NO]            NVARCHAR (50)   NULL,
    [PROCESS_REFF_NAME]          NVARCHAR (250)  NULL,
    [JOB_STATUS]                 NVARCHAR (20)   CONSTRAINT [DF_AMS_INTERFACE_DOCUMENT_REQUEST_JOB_STATUS] DEFAULT (N'HOLD') NULL,
    [FAILED_REMARK]              NVARCHAR (4000) NULL,
    [CRE_DATE]                   DATETIME        NOT NULL,
    [CRE_BY]                     NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                   DATETIME        NOT NULL,
    [MOD_BY]                     NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_AMS_INTERFACE_DOCUMENT_REQUEST] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data document request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data document request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data document request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe request pada data document request tersebut - BORROW, menginformasikan bahwa document tersebut sedang direquest untuk proses borrow - RETURN, menginformasikan bahwa document tersebut direquest untuk proses return - RELEASE, menginformasikan bahwa document tersebut direquest untuk dilakukan proses release', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lokasi dilakukan proses request pada proses document request tersebut - BRANCH, menginformasikan bahwa document tersebut direquest oleh cabang lain - DEPARTMENT, menginformasikan bahwa document tersebut direquest oleh department lain - THIRD PARTY, menginformasikan bahwa document tersebut direquest oleh pihak ke tiga - CLIENT, menginformasikan bahwa document tersebut direquest oleh client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_LOCATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Asal dari document yang direquest pada proses document request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_FROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tujuan dari document yang direquest pada proses document request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_TO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pihak yang melakukan proses request pada proses document request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses document request tersebut - HOLD, menginformasikan bahwa document yang direquest tersebut belum di proses - POST, menginformasikan bahwa document yang direquest tersebut sudah dilakukan proses posting', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukan proses document request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses document request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode document yang di request pada proses document request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'DOCUMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal proses request pada proses document request tersebut di proses', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'PROCESS_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor referensi pada proses document request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'PROCESS_REFF_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama referensi pada proses document request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AMS_INTERFACE_DOCUMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'PROCESS_REFF_NAME';

