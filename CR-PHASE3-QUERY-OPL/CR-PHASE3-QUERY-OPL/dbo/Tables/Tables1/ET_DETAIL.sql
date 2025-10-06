CREATE TABLE [dbo].[ET_DETAIL] (
    [ID]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [ET_CODE]            NVARCHAR (50)   NOT NULL,
    [ASSET_NO]           NVARCHAR (50)   NOT NULL,
    [OS_RENTAL_AMOUNT]   DECIMAL (18, 2) NOT NULL,
    [IS_TERMINATE]       NVARCHAR (1)    NOT NULL,
    [CRE_DATE]           DATETIME        NOT NULL,
    [CRE_BY]             NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    [MOD_DATE]           DATETIME        NOT NULL,
    [MOD_BY]             NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    [IS_APPROVE_TO_SELL] NVARCHAR (1)    NULL,
    [CREDIT_AMOUNT]      DECIMAL (18, 2) NULL,
    [REFUND_AMOUNT]      DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_ET_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_ET_DETAIL_AGREEMENT_ASSET] FOREIGN KEY ([ASSET_NO]) REFERENCES [dbo].[AGREEMENT_ASSET] ([ASSET_NO]),
    CONSTRAINT [FK_ET_DETAIL_ET_MAIN] FOREIGN KEY ([ET_CODE]) REFERENCES [dbo].[ET_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IDX_20250203_ET_DETAIL]
    ON [dbo].[ET_DETAIL]([ET_CODE] ASC, [IS_TERMINATE] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_ET_DETAIL_ASSET_NO_20250721]
    ON [dbo].[ET_DETAIL]([ASSET_NO] ASC)
    INCLUDE([ET_CODE]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode ET pada data ET detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_DETAIL', @level2type = N'COLUMN', @level2name = N'ET_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada data ET detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_DETAIL', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data tersebut dilakukan proses terminate?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ET_DETAIL', @level2type = N'COLUMN', @level2name = N'IS_TERMINATE';

