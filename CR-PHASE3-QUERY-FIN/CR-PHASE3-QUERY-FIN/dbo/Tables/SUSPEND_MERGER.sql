CREATE TABLE [dbo].[SUSPEND_MERGER] (
    [CODE]                 NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]          NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]          NVARCHAR (250)  NOT NULL,
    [MERGER_STATUS]        NVARCHAR (20)   NOT NULL,
    [MERGER_DATE]          DATETIME        NOT NULL,
    [MERGER_AMOUNT]        DECIMAL (18, 2) CONSTRAINT [DF_MERGER_SUSPEND_HEADER_RELEASE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [MERGER_REMARKS]       NVARCHAR (4000) CONSTRAINT [DF_MERGER_SUSPEND_HEADER_RELEASE_REMARKS] DEFAULT ((0)) NOT NULL,
    [MERGER_CURRENCY_CODE] NVARCHAR (3)    NOT NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_SUSPEND_MERGER] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data suspend merger tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MERGER', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data suspend merger tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MERGER', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data suspend merger tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MERGER', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status data pada proses suspend merger tersebut - HOLD, menginformasikan bahwa data suspend merger tersebut belum diproses - POST, menginformasikan bahwa data suspend merger tersebut telah diposting - CANCEL, menginformasikan bahwa data suspend merger tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MERGER', @level2type = N'COLUMN', @level2name = N'MERGER_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses merger pada data suspend merger tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MERGER', @level2type = N'COLUMN', @level2name = N'MERGER_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai merger pada data suspend merger tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MERGER', @level2type = N'COLUMN', @level2name = N'MERGER_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada data suspend merger tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MERGER', @level2type = N'COLUMN', @level2name = N'MERGER_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada data suspend merger tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MERGER', @level2type = N'COLUMN', @level2name = N'MERGER_CURRENCY_CODE';

