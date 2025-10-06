CREATE TABLE [dbo].[RECEIVED_TRANSACTION_DETAIL] (
    [ID]                        BIGINT          IDENTITY (1, 1) NOT NULL,
    [RECEIVED_TRANSACTION_CODE] NVARCHAR (50)   NOT NULL,
    [RECEIVED_REQUEST_CODE]     NVARCHAR (50)   NOT NULL,
    [ORIG_CURR_CODE]            NVARCHAR (3)    NOT NULL,
    [ORIG_AMOUNT]               DECIMAL (18, 2) NOT NULL,
    [EXCH_RATE]                 DECIMAL (18, 6) NOT NULL,
    [BASE_AMOUNT]               DECIMAL (18, 2) NOT NULL,
    [CRE_DATE]                  DATETIME        NOT NULL,
    [CRE_BY]                    NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                  DATETIME        NOT NULL,
    [MOD_BY]                    NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]            NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_RECEIVED_FROM_CORE_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_RECEIVED_FROM_CORE_DETAIL_RECEIVED_FROM_CORE] FOREIGN KEY ([RECEIVED_TRANSACTION_CODE]) REFERENCES [dbo].[RECEIVED_TRANSACTION] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_RECEIVED_FROM_CORE_DETAIL_RECEIVED_REQUEST] FOREIGN KEY ([RECEIVED_REQUEST_CODE]) REFERENCES [dbo].[RECEIVED_REQUEST] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode penerimaan from core pada data received transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'RECEIVED_TRANSACTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode received request pada data received transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'RECEIVED_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada data received transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'ORIG_CURR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai original pada data received transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'ORIG_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai tukar mata uang pada data received transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'EXCH_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai base amount pada data received transaction detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RECEIVED_TRANSACTION_DETAIL', @level2type = N'COLUMN', @level2name = N'BASE_AMOUNT';

