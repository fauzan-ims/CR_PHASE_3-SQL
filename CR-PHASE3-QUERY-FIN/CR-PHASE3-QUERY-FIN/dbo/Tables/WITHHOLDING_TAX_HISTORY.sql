CREATE TABLE [dbo].[WITHHOLDING_TAX_HISTORY] (
    [ID]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [BRANCH_CODE]         NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]         NVARCHAR (250)  NOT NULL,
    [PAYMENT_DATE]        DATETIME        NOT NULL,
    [PAYMENT_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_WITHHOLDING_TAX_HISTORY_PAYMENT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TAX_PAYER_REFF_CODE] NVARCHAR (50)   NULL,
    [TAX_TYPE]            NVARCHAR (5)    NOT NULL,
    [TAX_FILE_NO]         NVARCHAR (50)   NULL,
    [TAX_FILE_NAME]       NVARCHAR (250)  NULL,
    [TAX_PCT]             DECIMAL (9, 6)  CONSTRAINT [DF_WITHHOLDING_TAX_HISTORY_TAX_PCT] DEFAULT ((0)) NOT NULL,
    [TAX_AMOUNT]          DECIMAL (18, 2) CONSTRAINT [DF_WITHHOLDING_TAX_HISTORY_TAX_AMOUNT] DEFAULT ((0)) NULL,
    [REFF_NO]             NVARCHAR (50)   NOT NULL,
    [REFF_NAME]           NVARCHAR (250)  NOT NULL,
    [REMARK]              NVARCHAR (4000) NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_WITHHOLDING_TAX_HISTORY] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'kode pembayar pajak di master setting.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WITHHOLDING_TAX_HISTORY', @level2type = N'COLUMN', @level2name = N'TAX_PAYER_REFF_CODE';

