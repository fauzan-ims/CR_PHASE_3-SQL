CREATE TABLE [dbo].[RECEIPT_VOID_DETAIL] (
    [ID]                BIGINT        IDENTITY (1, 1) NOT NULL,
    [RECEIPT_VOID_CODE] NVARCHAR (50) NOT NULL,
    [RECEIPT_CODE]      NVARCHAR (50) NOT NULL,
    [CRE_DATE]          DATETIME      NOT NULL,
    [CRE_BY]            NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15) NOT NULL,
    [MOD_DATE]          DATETIME      NOT NULL,
    [MOD_BY]            NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_RECEIPT_VOID_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_RECEIPT_VOID_DETAIL_RECEIPT_MAIN] FOREIGN KEY ([RECEIPT_CODE]) REFERENCES [dbo].[RECEIPT_MAIN] ([CODE]),
    CONSTRAINT [FK_RECEIPT_VOID_DETAIL_RECEIPT_VOID] FOREIGN KEY ([RECEIPT_VOID_CODE]) REFERENCES [dbo].[RECEIPT_VOID] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_VOID_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kwitansi yang dilakukan proses void', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_VOID_DETAIL', @level2type = N'COLUMN', @level2name = N'RECEIPT_VOID_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kwitansi pada proses receipt void detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIPT_VOID_DETAIL', @level2type = N'COLUMN', @level2name = N'RECEIPT_CODE';

