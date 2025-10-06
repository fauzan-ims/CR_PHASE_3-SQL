CREATE TABLE [dbo].[RECEIPT_REGISTER_DETAIL] (
    [ID]             BIGINT         IDENTITY (1, 1) NOT NULL,
    [REGISTER_CODE]  NVARCHAR (50)  NOT NULL,
    [RECEIPT_NO]     NVARCHAR (150) NOT NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_RECEIPT_REGISTER_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_RECEIPT_REGISTER_DETAIL_RECEIPT_REGISTER] FOREIGN KEY ([REGISTER_CODE]) REFERENCES [dbo].[RECEIPT_REGISTER] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_REGISTER_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode register pada proses receipt register detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_REGISTER_DETAIL', @level2type = N'COLUMN', @level2name = N'REGISTER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kwitansi pada proses receipt register detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_REGISTER_DETAIL', @level2type = N'COLUMN', @level2name = N'RECEIPT_NO';

