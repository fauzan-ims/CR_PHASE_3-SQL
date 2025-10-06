CREATE TABLE [dbo].[RECEIVED_REQUEST] (
    [CODE]                      NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]               NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]               NVARCHAR (250)  NOT NULL,
    [RECEIVED_SOURCE]           NVARCHAR (50)   NOT NULL,
    [RECEIVED_REQUEST_DATE]     DATETIME        NOT NULL,
    [RECEIVED_SOURCE_NO]        NVARCHAR (50)   NOT NULL,
    [RECEIVED_STATUS]           NVARCHAR (10)   NOT NULL,
    [RECEIVED_CURRENCY_CODE]    NVARCHAR (3)    CONSTRAINT [DF_RECEIVED_REQUEST_RECEIVED_CURRENCY_CODE] DEFAULT (N'IDR') NOT NULL,
    [RECEIVED_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_RECEIVED_REQUEST_RECEIVED_AMOUNT] DEFAULT ((0)) NOT NULL,
    [RECEIVED_REMARKS]          NVARCHAR (4000) CONSTRAINT [DF_RECEIVED_REQUEST_RECEIVED_REMARKS] DEFAULT ('') NOT NULL,
    [RECEIVED_TRANSACTION_CODE] NVARCHAR (50)   NULL,
    [BRANCH_BANK_CODE]          NVARCHAR (50)   NULL,
    [BRANCH_BANK_NAME]          NVARCHAR (250)  NULL,
    [BRANCH_BANK_GL_LINK_CODE]  NVARCHAR (50)   NULL,
    [CRE_DATE]                  DATETIME        NOT NULL,
    [CRE_BY]                    NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                  DATETIME        NOT NULL,
    [MOD_BY]                    NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_RECEIVED_REQUEST] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada data received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada data received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Source pada data received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'RECEIVED_SOURCE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal request penerimaan pada data received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'RECEIVED_REQUEST_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor source penerimaan pada data received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'RECEIVED_SOURCE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses received request tersebut - HOLD, menginformasikan bahwa data received request tersebut belum di proses - ON PROCESS, menginformasikan bahwa data received request tersebut sedang dalam proses - POST, menginformasikan bahwa data received request tersebut telah diposting', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'RECEIVED_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada data received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'RECEIVED_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai penerimaan pada data received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'RECEIVED_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada data received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'RECEIVED_REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode transaksi pada data received request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_REQUEST', @level2type = N'COLUMN', @level2name = N'RECEIVED_TRANSACTION_CODE';

