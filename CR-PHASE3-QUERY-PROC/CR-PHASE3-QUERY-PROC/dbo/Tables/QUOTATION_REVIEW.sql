CREATE TABLE [dbo].[QUOTATION_REVIEW] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [COMPANY_CODE]          NVARCHAR (50)   CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_COMPANY_CODE] DEFAULT ('') NOT NULL,
    [QUOTATION_REVIEW_DATE] DATETIME        NOT NULL,
    [EXPIRED_DATE]          DATETIME        NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   CONSTRAINT [DF_Table_1_BRANCH_REQUEST_CODE] DEFAULT ('') NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  CONSTRAINT [DF_Table_1_BRANCH_REQUEST_NAME] DEFAULT ('') NOT NULL,
    [DIVISION_CODE]         NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_DIVISION_CODE] DEFAULT ('') NULL,
    [DIVISION_NAME]         NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_DIVISION_NAME] DEFAULT ('') NULL,
    [DEPARTMENT_CODE]       NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_DEPARTMENT_CODE] DEFAULT ('') NULL,
    [DEPARTMENT_NAME]       NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_DEPARTMENT_NAME] DEFAULT ('') NULL,
    [REQUESTOR_CODE]        NVARCHAR (50)   NULL,
    [REQUESTOR_NAME]        NVARCHAR (250)  NULL,
    [STATUS]                NVARCHAR (20)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_STATUS] DEFAULT ('') NOT NULL,
    [DATE_FLAG]             DATETIME        NULL,
    [REMARK]                NVARCHAR (4000) COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_REMARK] DEFAULT ('') NULL,
    [UNIT_FROM]             NVARCHAR (60)   NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_CRE_BY] DEFAULT ('') NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_CRE_IP_ADDRESS] DEFAULT ('') NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_MOD_BY] DEFAULT ('') NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_MOD_IP_ADDRESS] DEFAULT ('') NOT NULL,
    [ITEM_CODE]             NVARCHAR (50)   NULL,
    CONSTRAINT [PK_PROCUREMENT_QUOTATION_REVIEW] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PERUSAHAAN (DSF)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'COMPANY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TANGGAL REVIEW QUOTATION', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'QUOTATION_REVIEW_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TANGGAL KADALUARSA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'EXPIRED_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE CABANG, DIAMBIL DARI MODULE IFINSYS TABLE SYS BRANCH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA CABANG, DIAMBIL DARI MODULE IFINSYS TABLE SYS BRANCH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE DIVISI, DIAMBIL DARI MODULE IFINSYS TABLE SYS DIVISION', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'DIVISION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA DIVISI, DIAMBIL DARI MODULE IFINSYS TABLE SYS DIVISION', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'DIVISION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE DEPARTEMEN, DIAMBIL DARI MODULE IFINSYS TABLE SYS DEPARTMENT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'DEPARTMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA DEPARTEMEN, DIAMBIL DARI MODULE IFINSYS TABLE SYS DEPARTMENT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'DEPARTMENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PEMOHON, DIAMBIL DARI MODULE IFINSYS TABLE SYS EMPLOYEE MAIN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'REQUESTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA PEMOHON, DIAMBIL DARI MODULE IFINSYS TABLE SYS EMPLOYEE MAIN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'REQUESTOR_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'STATUS TRANSAKSI DDL VALUE NEW, POST, CANCEL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'DATE_FLAG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KETERANGAN TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'REMARK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ASAL UNIT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW', @level2type = N'COLUMN', @level2name = N'UNIT_FROM';

