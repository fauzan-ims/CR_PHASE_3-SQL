CREATE TABLE [dbo].[PROCUREMENT_REQUEST] (
    [CODE]               NVARCHAR (50)   NOT NULL,
    [COMPANY_CODE]       NVARCHAR (50)   NOT NULL,
    [REQUEST_DATE]       DATETIME        NOT NULL,
    [REQUESTOR_CODE]     NVARCHAR (50)   CONSTRAINT [DF_PROCUREMENT_REQUEST_REQUESTOR_CODE] DEFAULT ('') NOT NULL,
    [REQUESTOR_NAME]     NVARCHAR (250)  CONSTRAINT [DF_PROCUREMENT_REQUEST_REQUESTOR_CODE1] DEFAULT ('') NOT NULL,
    [REQUIREMENT_TYPE]   NVARCHAR (50)   CONSTRAINT [DF_PROCUREMENT_REQUEST_REQUIREMENT_TYPE] DEFAULT ('') NOT NULL,
    [BRANCH_CODE]        NVARCHAR (50)   CONSTRAINT [DF_PROCUREMENT_REQUEST_BRANCH_CODE] DEFAULT ('') NOT NULL,
    [BRANCH_NAME]        NVARCHAR (250)  CONSTRAINT [DF_PROCUREMENT_REQUEST_BRANCH_NAME] DEFAULT ('') NOT NULL,
    [DIVISION_CODE]      NVARCHAR (50)   CONSTRAINT [DF_PROCUREMENT_REQUEST_DIVISION_CODE] DEFAULT ('') NOT NULL,
    [DIVISION_NAME]      NVARCHAR (250)  CONSTRAINT [DF_PROCUREMENT_REQUEST_DIVISION_NAME] DEFAULT ('') NOT NULL,
    [DEPARTMENT_CODE]    NVARCHAR (50)   CONSTRAINT [DF_PROCUREMENT_REQUEST_DEPARTMENT_CODE] DEFAULT ('') NOT NULL,
    [DEPARTMENT_NAME]    NVARCHAR (250)  CONSTRAINT [DF_PROCUREMENT_REQUEST_DEPARTMENT_NAME] DEFAULT ('') NOT NULL,
    [STATUS]             NVARCHAR (20)   CONSTRAINT [DF_PROCUREMENT_REQUEST_STATUS] DEFAULT ('') NOT NULL,
    [REMARK]             NVARCHAR (4000) CONSTRAINT [DF_PROCUREMENT_REQUEST_REMARK] DEFAULT ('') NOT NULL,
    [REFF_NO]            NVARCHAR (50)   NULL,
    [PROCUREMENT_TYPE]   NVARCHAR (15)   NULL,
    [IS_REIMBURSE]       NVARCHAR (1)    NULL,
    [TO_PROVINCE_CODE]   NVARCHAR (50)   NULL,
    [TO_PROVINCE_NAME]   NVARCHAR (250)  NULL,
    [TO_CITY_CODE]       NVARCHAR (50)   NULL,
    [TO_CITY_NAME]       NVARCHAR (250)  NULL,
    [TO_AREA_PHONE_NO]   NVARCHAR (4)    NULL,
    [TO_PHONE_NO]        NVARCHAR (15)   NULL,
    [ETA_DATE]           DATETIME        NULL,
    [TO_ADDRESS]         NVARCHAR (4000) NULL,
    [REMARK_RETURN]      NVARCHAR (4000) NULL,
    [ASSET_NO]           NVARCHAR (50)   NULL,
    [CRE_DATE]           DATETIME        NOT NULL,
    [CRE_BY]             NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]           DATETIME        NOT NULL,
    [MOD_BY]             NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [FROM_PROVINCE_CODE] NVARCHAR (50)   NULL,
    [FROM_PROVINCE_NAME] NVARCHAR (250)  NULL,
    [FROM_CITY_CODE]     NVARCHAR (50)   NULL,
    [FROM_CITY_NAME]     NVARCHAR (250)  NULL,
    [FROM_AREA_PHONE_NO] NVARCHAR (4)    NULL,
    [FROM_PHONE_NO]      NVARCHAR (15)   NULL,
    [FROM_ADDRESS]       NVARCHAR (4000) NULL,
    [MOBILISASI_TYPE]    NVARCHAR (50)   NULL,
    [APPLICATION_NO]     NVARCHAR (50)   NULL,
    [BUILT_YEAR]         NVARCHAR (4)    NULL,
    [ASSET_COLOUR]       NVARCHAR (50)   NULL,
    CONSTRAINT [PK_PROCUREMENT_REQUEST_1] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_PROCUREMENT_REQUEST_STATUS]
    ON [dbo].[PROCUREMENT_REQUEST]([STATUS] ASC)
    INCLUDE([ASSET_NO]);


GO
CREATE NONCLUSTERED INDEX [IDX_PROCUREMENT_TYPE_20241219]
    ON [dbo].[PROCUREMENT_REQUEST]([PROCUREMENT_TYPE] ASC, [STATUS] ASC)
    INCLUDE([ASSET_NO]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CODE TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PERUSAHAAN (DSF)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'COMPANY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TANGGAL PENGAJUAN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PEMOHON, DIAMBIL DARI MODULE IFINSYS TABLE SYS EMPLOYEE MAIN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUESTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA PEMOHON, DIAMBIL DARI MODULE IFINSYS TABLE SYS EMPLOYEE MAIN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUESTOR_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TIPE PERSYARATAN, DDL VALUE URGENT & NON-URGENT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUIREMENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE CABANG, DIAMBIL DARI MODULE IFINSYS TABLE SYS BRANCH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA CABANG, DIAMBIL DARI MODULE IFINSYS TABLE SYS BRANCH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE DIVISI, DIAMBIL DARI MODULE IFINSYS TABLE SYS DIVISION', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'DIVISION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA DIVISI, DIAMBIL DARI MODULE IFINSYS TABLE SYS DIVISION', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'DIVISION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE DEPARTEMEN, DIAMBIL DARI MODULE IFINSYS TABLE IFINSYS DEPARTMENT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'DEPARTMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA DEPARTEMEN, DIAMBIL DARI MODULE IFINSYS TABLE IFINSYS DEPARTMENT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'DEPARTMENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'STATUS TRANSAKSI, DDL VALUE NEW, ON PROGRESS, POST, VERIFIED, CANCEL, REJECTED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KETERANGAN TRANKSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REMARK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REFF_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KETERANGAN KENAPA TRANSAKSI DI KEMBALIKAN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST', @level2type = N'COLUMN', @level2name = N'REMARK_RETURN';

