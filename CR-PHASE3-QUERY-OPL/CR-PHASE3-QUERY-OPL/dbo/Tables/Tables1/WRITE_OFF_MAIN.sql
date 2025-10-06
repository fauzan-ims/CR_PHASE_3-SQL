CREATE TABLE [dbo].[WRITE_OFF_MAIN] (
    [CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]    NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]    NVARCHAR (250)  NOT NULL,
    [WO_STATUS]      NVARCHAR (10)   NOT NULL,
    [WO_DATE]        DATETIME        NOT NULL,
    [WO_TYPE]        NVARCHAR (10)   NULL,
    [WO_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_WRITE_OFF_MAIN_WO_AMOUNT] DEFAULT ((0)) NOT NULL,
    [WO_REMARKS]     NVARCHAR (4000) NOT NULL,
    [AGREEMENT_NO]   NVARCHAR (50)   NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_WRITE_OFF_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_WRITE_OFF_MAIN_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_MAIN', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_MAIN', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses write off', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_MAIN', @level2type = N'COLUMN', @level2name = N'WO_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pada proses write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_MAIN', @level2type = N'COLUMN', @level2name = N'WO_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_MAIN', @level2type = N'COLUMN', @level2name = N'WO_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada proses write off tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WRITE_OFF_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';

