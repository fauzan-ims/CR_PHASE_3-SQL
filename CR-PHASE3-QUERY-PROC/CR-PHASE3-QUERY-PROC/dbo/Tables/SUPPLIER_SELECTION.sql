CREATE TABLE [dbo].[SUPPLIER_SELECTION] (
    [CODE]            NVARCHAR (50)   NOT NULL,
    [COMPANY_CODE]    NVARCHAR (50)   NOT NULL,
    [QUOTATION_CODE]  NVARCHAR (50)   NOT NULL,
    [SELECTION_DATE]  DATETIME        NOT NULL,
    [BRANCH_CODE]     NVARCHAR (50)   CONSTRAINT [DF_SUPPLIER_SELECTION_BRANCH_CODE] DEFAULT ('') NOT NULL,
    [BRANCH_NAME]     NVARCHAR (250)  CONSTRAINT [DF_SUPPLIER_SELECTION_BRANCH_NAME] DEFAULT ('') NOT NULL,
    [DIVISION_CODE]   NVARCHAR (50)   CONSTRAINT [DF_SUPPLIER_SELECTION_DIVISION_CODE] DEFAULT ('') NULL,
    [DIVISION_NAME]   NVARCHAR (250)  CONSTRAINT [DF_SUPPLIER_SELECTION_DIVISION_NAME] DEFAULT ('') NULL,
    [DEPARTMENT_CODE] NVARCHAR (50)   CONSTRAINT [DF_SUPPLIER_SELECTION_DEPARTMENT_CODE] DEFAULT ('') NULL,
    [DEPARTMENT_NAME] NVARCHAR (250)  CONSTRAINT [DF_SUPPLIER_SELECTION_DEPARTMENT_NAME] DEFAULT ('') NULL,
    [REQUESTOR_CODE]  NVARCHAR (50)   NULL,
    [REQUESTOR_NAME]  NVARCHAR (250)  NULL,
    [STATUS]          NVARCHAR (50)   CONSTRAINT [DF_SUPPLIER_SELECTION_STATUS] DEFAULT ('') NULL,
    [REMARK]          NVARCHAR (4000) CONSTRAINT [DF_SUPPLIER_SELECTION_REMARK] DEFAULT ('') NULL,
    [CRE_DATE]        DATETIME        NOT NULL,
    [CRE_BY]          NVARCHAR (15)   CONSTRAINT [DF_SUPPLIER_SELECTION_CRE_BY] DEFAULT ('') NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15)   CONSTRAINT [DF_SUPPLIER_SELECTION_CRE_IP_ADDRESS] DEFAULT ('') NOT NULL,
    [MOD_DATE]        DATETIME        NOT NULL,
    [MOD_BY]          NVARCHAR (15)   CONSTRAINT [DF_SUPPLIER_SELECTION_MOD_BY] DEFAULT ('') NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15)   COLLATE Latin1_General_CS_AI CONSTRAINT [DF_SUPPLIER_SELECTION_MOD_IP_ADDRESS] DEFAULT ('') NOT NULL,
    [DATE_FLAG]       DATETIME        NULL,
    [UNIT_FROM]       NVARCHAR (50)   NULL,
    [COUNT_RETURN]    INT             NULL,
    CONSTRAINT [PK_SUPPLIER_SELECTION] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PERUSAHAAN (DSF)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'COMPANY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE QUOTATION', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'QUOTATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TANGGAL PEMILIHAN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'SELECTION_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE CABANG, DIAMBIL DARI MODULE IFINSYS TABLE SYS BRANCH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA CABANG, DIAMBIL DARI MODULE IFINSYS TABLE SYS BRANCH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE DIVISI, DIAMBIL DARI MODULE IFINSYS TABLE SYS DIVISION', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'DIVISION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA DIVISI, DIAMBIL DARI MODULE IFINSYS TABLE SYS DIVISION', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'DIVISION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE DEPARTEMEN, DIAMBIL DARI MODULE IFINSYS TABLE SYS DEPARTMENT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'DEPARTMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA DEPARTEMEN, DIAMBIL DARI MODULE IFINSYS TABLE SYS DEPARTMENT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'DEPARTMENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'REQUESTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'REQUESTOR_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'STATUS TRANSAKSI, DDL VALUE NEW, POST, CANCEL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KETERANGAN TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUPPLIER_SELECTION', @level2type = N'COLUMN', @level2name = N'REMARK';

