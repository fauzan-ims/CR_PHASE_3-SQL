CREATE TABLE [dbo].[AGREEMENT_LOG] (
    [ID]             BIGINT          IDENTITY (1, 1) NOT NULL,
    [AGREEMENT_NO]   NVARCHAR (50)   NOT NULL,
    [ASSET_NO]       NVARCHAR (50)   NULL,
    [LOG_SOURCE_NO]  NVARCHAR (50)   NOT NULL,
    [LOG_DATE]       DATETIME        NOT NULL,
    [LOG_REMARKS]    NVARCHAR (4000) NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_AGREEMENT_LOG] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_AGREEMENT_LOG_AGREEMENT_ASSET] FOREIGN KEY ([ASSET_NO]) REFERENCES [dbo].[AGREEMENT_ASSET] ([ASSET_NO]),
    CONSTRAINT [FK_AGREEMENT_LOG_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_LOG', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_LOG', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_LOG', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor transaksi dari dari source aktifity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_LOG', @level2type = N'COLUMN', @level2name = N'LOG_SOURCE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal aktifity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_LOG', @level2type = N'COLUMN', @level2name = N'LOG_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan aktifity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_LOG', @level2type = N'COLUMN', @level2name = N'LOG_REMARKS';

