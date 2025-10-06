CREATE TABLE [dbo].[INSURANCE_POLICY_MAIN_PERIOD] (
    [CODE]              NVARCHAR (50)   NOT NULL,
    [POLICY_CODE]       NVARCHAR (50)   NOT NULL,
    [RATE_DEPRECIATION] DECIMAL (9, 6)  CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PERIOD_RATE_DEPRECIATION] DEFAULT ((0)) NOT NULL,
    [COVERAGE_CODE]     NVARCHAR (50)   NOT NULL,
    [IS_MAIN_COVERAGE]  NVARCHAR (1)    NULL,
    [YEAR_PERIODE]      INT             CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PERIOD_YEAR] DEFAULT ((1)) NOT NULL,
    [BUY_AMOUNT]        DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PERIOD_BUY_AMMOUNT] DEFAULT ((0)) NOT NULL,
    [DISCOUNT_PCT]      DECIMAL (9, 6)  CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PERIOD_DISCOUNT_PCT] DEFAULT ((0)) NOT NULL,
    [DISCOUNT_AMOUNT]   DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PERIOD_PREMI_DISCOUNT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ADMIN_FEE_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PERIOD_ADMIN_FEE] DEFAULT ((0)) NOT NULL,
    [STAMP_FEE_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PERIOD_STAMP_FEE] DEFAULT ((0)) NOT NULL,
    [ADJUSTMENT_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PERIOD_INITIAL_STAMP_FEE_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [TOTAL_BUY_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_MAIN_PERIOD_TOTAL_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]          DATETIME        NOT NULL,
    [CRE_BY]            NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15)   NOT NULL,
    [MOD_DATE]          DATETIME        NOT NULL,
    [MOD_BY]            NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_INSURANCE_POLICY_MAIN_PERIOD] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_INSURANCE_POLICY_MAIN_PERIOD_INSURANCE_POLICY_MAIN] FOREIGN KEY ([POLICY_CODE]) REFERENCES [dbo].[INSURANCE_POLICY_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_INSURANCE_POLICY_MAIN_PERIOD_MASTER_COVERAGE] FOREIGN KEY ([COVERAGE_CODE]) REFERENCES [dbo].[MASTER_COVERAGE] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada periode polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode polis asuransi pada periode polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD', @level2type = N'COLUMN', @level2name = N'POLICY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Presentase depresiasi pada periode polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD', @level2type = N'COLUMN', @level2name = N'RATE_DEPRECIATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode coverage pada periode polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD', @level2type = N'COLUMN', @level2name = N'COVERAGE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data coverage tersebut merupakan data main coverage?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD', @level2type = N'COLUMN', @level2name = N'IS_MAIN_COVERAGE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Period tahun pada periode polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD', @level2type = N'COLUMN', @level2name = N'YEAR_PERIODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai premi beli asuransi ke maskapai asuransi pada periode polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD', @level2type = N'COLUMN', @level2name = N'BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persentase rate diskon premi asuransi pada periode polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD', @level2type = N'COLUMN', @level2name = N'DISCOUNT_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai diskon asuransi pada periode polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD', @level2type = N'COLUMN', @level2name = N'DISCOUNT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai biaya admin pada periode polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD', @level2type = N'COLUMN', @level2name = N'ADMIN_FEE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai biaya materai pada periode polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD', @level2type = N'COLUMN', @level2name = N'STAMP_FEE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai adjustment asuransi pada periode polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD', @level2type = N'COLUMN', @level2name = N'ADJUSTMENT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total harga beli asuransi dari maskapai asuransi pada periode polis asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_MAIN_PERIOD', @level2type = N'COLUMN', @level2name = N'TOTAL_BUY_AMOUNT';

