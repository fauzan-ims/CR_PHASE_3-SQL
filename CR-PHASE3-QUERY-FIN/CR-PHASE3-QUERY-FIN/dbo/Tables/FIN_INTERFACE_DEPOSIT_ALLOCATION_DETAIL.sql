CREATE TABLE [dbo].[FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL] (
    [ID]                                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [FIN_INTERFACE_DEPOSIT_ALLOCATION_CODE] NVARCHAR (50)   NOT NULL,
    [TRANSACTION_CODE]                      NVARCHAR (50)   NOT NULL,
    [INNITIAL_AMOUNT]                       DECIMAL (18, 2) NOT NULL,
    [ORIG_AMOUNT]                           DECIMAL (18, 2) CONSTRAINT [DF_FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL_ORIG_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ORIG_CURRENCY_CODE]                    NVARCHAR (3)    NOT NULL,
    [EXCH_RATE]                             DECIMAL (18, 6) CONSTRAINT [DF_FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL_EXCH_RATE] DEFAULT ((0)) NOT NULL,
    [BASE_AMOUNT]                           DECIMAL (18, 2) CONSTRAINT [DF_FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL_BASE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INSTALLMENT_NO]                        INT             NULL,
    [REMARK]                                NVARCHAR (4000) NOT NULL,
    [CRE_DATE]                              DATETIME        NOT NULL,
    [CRE_BY]                                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                              DATETIME        NOT NULL,
    [MOD_BY]                                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                        NVARCHAR (15)   NOT NULL,
    CONSTRAINT [FK_FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL_CORE_INTERFACE_ALLOCATION_DEPOSIT] FOREIGN KEY ([FIN_INTERFACE_DEPOSIT_ALLOCATION_CODE]) REFERENCES [dbo].[FIN_INTERFACE_DEPOSIT_ALLOCATION] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode alokasi deposit pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode transaksi pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'TRANSACTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai alokasi original pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang original pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'ORIG_CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'BASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses deposit allocation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL', @level2type = N'COLUMN', @level2name = N'REMARK';

