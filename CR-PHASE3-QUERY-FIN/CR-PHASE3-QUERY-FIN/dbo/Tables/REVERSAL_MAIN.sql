CREATE TABLE [dbo].[REVERSAL_MAIN] (
    [CODE]             NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]      NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]      NVARCHAR (250)  NOT NULL,
    [REVERSAL_STATUS]  NVARCHAR (10)   NOT NULL,
    [REVERSAL_DATE]    DATETIME        NOT NULL,
    [REVERSAL_REMARKS] NVARCHAR (4000) NOT NULL,
    [SOURCE_REFF_CODE] NVARCHAR (50)   NOT NULL,
    [SOURCE_REFF_NAME] NVARCHAR (250)  NOT NULL,
    [CRE_DATE]         DATETIME        NOT NULL,
    [CRE_BY]           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]         DATETIME        NOT NULL,
    [MOD_BY]           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_REVERSAL_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses reversal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REVERSAL_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses reversal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REVERSAL_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses reversal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REVERSAL_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses reversal tersebut - HOLD, menginformasikan bahwa data reversal tersebut belum diproses - POST, menginformasikan bahwa data reversal tersebut telah diposting - CANCEL, menginformasikan bahwa data reversal tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REVERSAL_MAIN', @level2type = N'COLUMN', @level2name = N'REVERSAL_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses reversal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REVERSAL_MAIN', @level2type = N'COLUMN', @level2name = N'REVERSAL_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses reversal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REVERSAL_MAIN', @level2type = N'COLUMN', @level2name = N'REVERSAL_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode referensi source pada proses reversal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REVERSAL_MAIN', @level2type = N'COLUMN', @level2name = N'SOURCE_REFF_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama referensi source pada proses reversal tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'REVERSAL_MAIN', @level2type = N'COLUMN', @level2name = N'SOURCE_REFF_NAME';

