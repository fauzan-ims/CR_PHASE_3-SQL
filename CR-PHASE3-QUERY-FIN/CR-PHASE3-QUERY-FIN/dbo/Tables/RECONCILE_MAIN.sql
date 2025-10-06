CREATE TABLE [dbo].[RECONCILE_MAIN] (
    [CODE]                      NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]               NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]               NVARCHAR (250)  NOT NULL,
    [RECONCILE_STATUS]          NVARCHAR (10)   NOT NULL,
    [RECONCILE_DATE]            DATETIME        NOT NULL,
    [RECONCILE_FROM_VALUE_DATE] DATETIME        NOT NULL,
    [RECONCILE_TO_VALUE_DATE]   DATETIME        NOT NULL,
    [RECONCILE_REMARKS]         NVARCHAR (4000) NOT NULL,
    [BRANCH_BANK_CODE]          NVARCHAR (50)   NOT NULL,
    [BRANCH_BANK_NAME]          NVARCHAR (250)  NOT NULL,
    [BANK_GL_LINK_CODE]         NVARCHAR (50)   NOT NULL,
    [SYSTEM_AMOUNT]             DECIMAL (18, 2) CONSTRAINT [DF_RECONCILE_MAIN_SYSTEM_AMOUNT] DEFAULT ((0)) NOT NULL,
    [UPLOAD_AMOUNT]             DECIMAL (18, 2) CONSTRAINT [DF_RECONCILE_MAIN_UPLOAD_AMOUNT] DEFAULT ((0)) NOT NULL,
    [FILE_NAME]                 NVARCHAR (250)  NULL,
    [PATHS]                     NVARCHAR (250)  NULL,
    [CRE_DATE]                  DATETIME        NOT NULL,
    [CRE_BY]                    NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                  DATETIME        NOT NULL,
    [MOD_BY]                    NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_RECONCILE_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses rekonsel tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses rekonsel tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses rekonsel tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses rekonsel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'RECONCILE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal awal dilakukan proses rekonsel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'RECONCILE_FROM_VALUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal akhir dilakukan proses rekonsel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'RECONCILE_TO_VALUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses rekonsel tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'RECONCILE_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang bank pada proses rekonsel tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_BANK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang bank pada proses rekonsel tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang bank pada data transaksi penerimaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'BANK_GL_LINK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai rekonsel yang terdapat pada sistem', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'SYSTEM_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai rekonsel yang diupload kedalam sistem', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'UPLOAD_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama file yang diupload pada proses rekonsel tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama folder file yang diupload pada proses rekonsel tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_MAIN', @level2type = N'COLUMN', @level2name = N'PATHS';

