CREATE TABLE [dbo].[INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT] (
    [ID]                         BIGINT          IDENTITY (1, 1) NOT NULL,
    [POLICY_CODE]                NVARCHAR (50)   NOT NULL,
    [YEAR_PERIODE]               INT             CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT_YEAR_PERIODE] DEFAULT ((1)) NOT NULL,
    [ADJUSTMENT_BUY_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT_ADJUSTMENT_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ADJUSTMENT_ADMIN_AMOUNT]    DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT_ADJUSTMENT_ADMIN_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ADJUSTMENT_DISCOUNT_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT_ADJUSTMENT_DISCOUNT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                   DATETIME        NOT NULL,
    [CRE_BY]                     NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                   DATETIME        NOT NULL,
    [MOD_BY]                     NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT_INSURANCE_POLICY_MAIN] FOREIGN KEY ([POLICY_CODE]) REFERENCES [dbo].[INSURANCE_POLICY_MAIN] ([CODE]) ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode polis asuransi pada proses adjustment periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT', @level2type = N'COLUMN', @level2name = N'POLICY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Periode tahun pada proses adjustment periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT', @level2type = N'COLUMN', @level2name = N'YEAR_PERIODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai adjustment beli asuransi pada proses adjustment periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT', @level2type = N'COLUMN', @level2name = N'ADJUSTMENT_BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai adjustment biaya admin pada proses adjustment periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT', @level2type = N'COLUMN', @level2name = N'ADJUSTMENT_ADMIN_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai adjustment diskon pada proses adjustment periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT', @level2type = N'COLUMN', @level2name = N'ADJUSTMENT_DISCOUNT_AMOUNT';

