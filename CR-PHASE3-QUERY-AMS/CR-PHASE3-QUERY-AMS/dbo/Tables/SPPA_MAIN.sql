CREATE TABLE [dbo].[SPPA_MAIN] (
    [CODE]             NVARCHAR (50)   NOT NULL,
    [SPPA_BRANCH_CODE] NVARCHAR (50)   NOT NULL,
    [SPPA_BRANCH_NAME] NVARCHAR (250)  NOT NULL,
    [SPPA_DATE]        DATETIME        NOT NULL,
    [SPPA_STATUS]      NVARCHAR (10)   NOT NULL,
    [SPPA_REMARKS]     NVARCHAR (4000) NOT NULL,
    [INSURANCE_CODE]   NVARCHAR (50)   NOT NULL,
    [INSURANCE_TYPE]   NVARCHAR (10)   CONSTRAINT [DF_SPPA_MAIN_INSURANCE_TYPE] DEFAULT (N'NON LIFE') NULL,
    [FILE_NAME]        NVARCHAR (250)  NULL,
    [PATHS]            NVARCHAR (250)  NULL,
    [PRINT_COUNT]      INT             NULL,
    [CRE_DATE]         DATETIME        NOT NULL,
    [CRE_BY]           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]         DATETIME        NOT NULL,
    [MOD_BY]           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_INSURANCE_SPPA_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_SPPA_MAIN_MASTER_INSURANCE] FOREIGN KEY ([INSURANCE_CODE]) REFERENCES [dbo].[MASTER_INSURANCE] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_MAIN', @level2type = N'COLUMN', @level2name = N'SPPA_BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_MAIN', @level2type = N'COLUMN', @level2name = N'SPPA_BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_MAIN', @level2type = N'COLUMN', @level2name = N'SPPA_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses SPPA tersebut - HOLD, menginformasikan bahwa data SPPA tersebutbelum diproses - ON PROCESS, menginformasikan bahwa data SPPA tersebut sedang di proses -POST, menginformasikan bahwa data SPPA tersebut sudah dilakukan proses posting - CANCEL, menginformasikan bahwa data SPPA tersebut sudah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_MAIN', @level2type = N'COLUMN', @level2name = N'SPPA_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_MAIN', @level2type = N'COLUMN', @level2name = N'SPPA_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode asuransi pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_MAIN', @level2type = N'COLUMN', @level2name = N'INSURANCE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe asuransi pada proses SPPA tersebut - LIFE, menginformasikan bahwa asuransi tersebut merupakan asuransi jiwa - NON LIFE, menginformasikan bahwa asuransi tersebut bukan merupakan asuransi jiwa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_MAIN', @level2type = N'COLUMN', @level2name = N'INSURANCE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama file yang diupload pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_MAIN', @level2type = N'COLUMN', @level2name = N'FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama folder file yang diupload pada proses SPPA tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_MAIN', @level2type = N'COLUMN', @level2name = N'PATHS';

