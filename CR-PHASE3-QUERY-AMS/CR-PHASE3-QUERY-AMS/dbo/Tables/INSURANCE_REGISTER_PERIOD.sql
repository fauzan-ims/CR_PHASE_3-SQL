CREATE TABLE [dbo].[INSURANCE_REGISTER_PERIOD] (
    [ID]                BIGINT          IDENTITY (1, 1) NOT NULL,
    [REGISTER_CODE]     NVARCHAR (50)   NOT NULL,
    [COVERAGE_CODE]     NVARCHAR (50)   NOT NULL,
    [IS_MAIN_COVERAGE]  NVARCHAR (1)    NULL,
    [YEAR_PERIODE]      INT             CONSTRAINT [DF_INSURANCE_REGISTER_PERIOD_YEAR_PERIODE] DEFAULT ((1)) NOT NULL,
    [BUY_AMOUNT]        DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_REGISTER_PERIOD_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ADMIN_FEE_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_REGISTER_PERIOD_INITIAL_ADMIN_FEE_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [STAMP_FEE_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_REGISTER_PERIOD_INITIAL_STAMP_FEE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DEDUCTION_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_REGISTER_PERIOD_DEDUCTION_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_BUY_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_REGISTER_PERIOD_TOTAL_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]          DATETIME        NOT NULL,
    [CRE_BY]            NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15)   NOT NULL,
    [MOD_DATE]          DATETIME        NOT NULL,
    [MOD_BY]            NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15)   NOT NULL,
    [SUM_INSURED]       DECIMAL (18, 2) NULL,
    [RATE_DEPRECIATION] DECIMAL (9, 6)  NULL,
    CONSTRAINT [PK_INSURANCE_REGISTER_PERIOD] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_INSURANCE_REGISTER_PERIOD_INSURANCE_REGISTER] FOREIGN KEY ([REGISTER_CODE]) REFERENCES [dbo].[INSURANCE_REGISTER] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_INSURANCE_REGISTER_PERIOD_MASTER_COVERAGE] FOREIGN KEY ([COVERAGE_CODE]) REFERENCES [dbo].[MASTER_COVERAGE] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_PERIOD', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode register pada proses pendaftaran periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_PERIOD', @level2type = N'COLUMN', @level2name = N'REGISTER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode coverage pada proses pendaftaran periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_PERIOD', @level2type = N'COLUMN', @level2name = N'COVERAGE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data coverage tersebut merupakan data main coverage?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_PERIOD', @level2type = N'COLUMN', @level2name = N'IS_MAIN_COVERAGE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Periode tahun pada proses pendaftaran periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_PERIOD', @level2type = N'COLUMN', @level2name = N'YEAR_PERIODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai premi beli asuransi dari maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_PERIOD', @level2type = N'COLUMN', @level2name = N'BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai biaya admin pada proses jual asuransi ke customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_PERIOD', @level2type = N'COLUMN', @level2name = N'ADMIN_FEE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Biaya materai pada proses register asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_PERIOD', @level2type = N'COLUMN', @level2name = N'STAMP_FEE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pengurangan pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_PERIOD', @level2type = N'COLUMN', @level2name = N'DEDUCTION_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total beli asuransi dari maskapai asuransi setelah ditambah biaya admi dan materai', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_PERIOD', @level2type = N'COLUMN', @level2name = N'TOTAL_BUY_AMOUNT';

