CREATE TABLE [dbo].[RECONCILE_TRANSACTION] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [RECONCILE_CODE]         NVARCHAR (50)   NOT NULL,
    [TRANSACTION_SOURCE]     NVARCHAR (250)  NOT NULL,
    [TRANSACTION_NO]         NVARCHAR (50)   NOT NULL,
    [TRANSACTION_REFF_NO]    NVARCHAR (50)   NOT NULL,
    [TRANSACTION_VALUE_DATE] DATETIME        NOT NULL,
    [TRANSACTION_AMOUNT]     DECIMAL (18, 2) NOT NULL,
    [IS_SYSTEM]              NVARCHAR (1)    CONSTRAINT [DF_RECONCILE_TRANSACTION_IS_SYSTEM] DEFAULT ((0)) NOT NULL,
    [IS_RECONCILE]           NVARCHAR (1)    CONSTRAINT [DF_RECONCILE_TRANSACTION_IS_RECON] DEFAULT ((0)) NOT NULL,
    [TYPE]                   NVARCHAR (3)    CONSTRAINT [DF_RECONCILE_TRANSACTION_TYPE] DEFAULT (N'AT') NOT NULL,
    [REMARK]                 NVARCHAR (4000) NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_RECONCILE_TRANSACTION] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_RECONCILE_TRANSACTION_RECONCILE_MAIN] FOREIGN KEY ([RECONCILE_CODE]) REFERENCES [dbo].[RECONCILE_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode rekonsel pada transaksi rekonsel tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'RECONCILE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_SOURCE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor transaksi pada transaksi rekonsel tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor referensi pada transaksi rekonsel tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_REFF_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal transaksi rekonsel tersebut diakui', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_VALUE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pada transaksi rekonsel tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah transaksi rekonsel tersebut berasal dari sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_SYSTEM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data tersebut dilakukan proses rekonsel?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECONCILE_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_RECONCILE';

