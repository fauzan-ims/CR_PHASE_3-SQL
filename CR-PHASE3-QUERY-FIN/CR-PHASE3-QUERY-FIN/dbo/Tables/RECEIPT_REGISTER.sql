CREATE TABLE [dbo].[RECEIPT_REGISTER] (
    [CODE]             NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]      NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]      NVARCHAR (250)  NOT NULL,
    [REGISTER_STATUS]  NVARCHAR (10)   NOT NULL,
    [REGISTER_DATE]    DATETIME        NOT NULL,
    [REGISTER_REMARKS] NVARCHAR (4000) NOT NULL,
    [RECEIPT_PREFIX]   NVARCHAR (50)   NULL,
    [RECEIPT_SEQUENCE] NVARCHAR (50)   NOT NULL,
    [RECEIPT_POSTFIX]  NVARCHAR (50)   NULL,
    [RECEIPT_NUMBER]   INT             NOT NULL,
    [CRE_DATE]         DATETIME        NOT NULL,
    [CRE_BY]           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]         DATETIME        NOT NULL,
    [MOD_BY]           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_RECEIPT_REGISTER] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data pendaftaran kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_REGISTER', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data pendaftaran kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_REGISTER', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data pendaftaran kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_REGISTER', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status data pada data pendaftaran kwitansi tersebut - HOLD, menginformasikan bahwa data pendaftaran kwitansi tersebut belum diproses - POST, menginformasikan bahwa data pendaftaran kwitansi tersebut telah diposting - CANCEL, menginformasikan bahwa data pendaftaran kwitansi tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_REGISTER', @level2type = N'COLUMN', @level2name = N'REGISTER_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses register pada data pendaftaran kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_REGISTER', @level2type = N'COLUMN', @level2name = N'REGISTER_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada data pendaftaran kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_REGISTER', @level2type = N'COLUMN', @level2name = N'REGISTER_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode prefix kwitansi pada data pendaftaran kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_REGISTER', @level2type = N'COLUMN', @level2name = N'RECEIPT_PREFIX';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor urut pada data pendaftaran kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_REGISTER', @level2type = N'COLUMN', @level2name = N'RECEIPT_SEQUENCE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode postfix kwitansi pada data pendaftaran kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_REGISTER', @level2type = N'COLUMN', @level2name = N'RECEIPT_POSTFIX';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kwitansi pada data pendaftaran kwitansi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_REGISTER', @level2type = N'COLUMN', @level2name = N'RECEIPT_NUMBER';

