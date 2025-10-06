CREATE TABLE [dbo].[WAIVED_OBLIGATION_DETAIL] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [WAIVED_OBLIGATION_CODE] NVARCHAR (50)   NOT NULL,
    [OBLIGATION_TYPE]        NVARCHAR (10)   NOT NULL,
    [OBLIGATION_NAME]        NVARCHAR (250)  CONSTRAINT [DF_WAIVED_OBLIGATION_DETAIL_OBLIGATION_NAME] DEFAULT (N'''NAME') NOT NULL,
    [INVOICE_NO]             NVARCHAR (50)   NOT NULL,
    [INSTALLMENT_NO]         INT             NOT NULL,
    [OBLIGATION_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_WAIVED_OBLIGATION_DETAIL_OBLIGATION_AMOUNT] DEFAULT ((0)) NOT NULL,
    [WAIVED_AMOUNT]          DECIMAL (18, 2) CONSTRAINT [DF_WAIVED_OBLIGATION_DETAIL_WAIVE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [ASSET_NO]               NVARCHAR (50)   NULL,
    CONSTRAINT [PK_WAIVED_OBLIGATION_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WAIVED_OBLIGATION_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode waived obligation pada data waived obligation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WAIVED_OBLIGATION_DETAIL', @level2type = N'COLUMN', @level2name = N'WAIVED_OBLIGATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran pada data waived obligation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WAIVED_OBLIGATION_DETAIL', @level2type = N'COLUMN', @level2name = N'INSTALLMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai obligasi pada data waived obligation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WAIVED_OBLIGATION_DETAIL', @level2type = N'COLUMN', @level2name = N'OBLIGATION_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai yang dilakukan proses waived pada data waived obligation detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WAIVED_OBLIGATION_DETAIL', @level2type = N'COLUMN', @level2name = N'WAIVED_AMOUNT';

