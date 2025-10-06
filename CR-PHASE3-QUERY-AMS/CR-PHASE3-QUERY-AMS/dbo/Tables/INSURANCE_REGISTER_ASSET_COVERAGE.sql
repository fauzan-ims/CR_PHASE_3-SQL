CREATE TABLE [dbo].[INSURANCE_REGISTER_ASSET_COVERAGE] (
    [ID]                       BIGINT          IDENTITY (1, 1) NOT NULL,
    [REGISTER_ASSET_CODE]      NVARCHAR (50)   NOT NULL,
    [RATE_DEPRECIATION]        DECIMAL (9, 6)  CONSTRAINT [DF_INSURANCE_REGISTER_ASSET_COVERAGE_RATE_DEPRECIATION] DEFAULT ((0)) NOT NULL,
    [IS_LOADING]               NVARCHAR (1)    NOT NULL,
    [COVERAGE_CODE]            NVARCHAR (50)   NOT NULL,
    [YEAR_PERIODE]             INT             CONSTRAINT [DF_INSURANCE_REGISTER_ASSET_COVERAGE_YEAR_PERIODE] DEFAULT ((1)) NOT NULL,
    [INITIAL_BUY_RATE]         DECIMAL (9, 6)  CONSTRAINT [DF_INSURANCE_REGISTER_ASSET_COVERAGE_INITIAL_BUY_RATE] DEFAULT ((0)) NOT NULL,
    [INITIAL_BUY_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_REGISTER_ASSET_COVERAGE_INITIAL_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INITIAL_DISCOUNT_PCT]     DECIMAL (9, 6)  CONSTRAINT [DF_INSURANCE_REGISTER_ASSET_COVERAGE_INITIAL_DISCOUNT_PCT] DEFAULT ((0)) NOT NULL,
    [INITIAL_DISCOUNT_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_REGISTER_ASSET_COVERAGE_INITIAL_DISCOUNT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INITIAL_ADMIN_FEE_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_REGISTER_ASSET_COVERAGE_INITIAL_BUY_ADMIN_FEE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [INITIAL_STAMP_FEE_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_REGISTER_ASSET_COVERAGE_INITIAL_STAMP_FEE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [BUY_AMOUNT]               DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_REGISTER_ASSET_COVERAGE_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [SPPA_CODE]                NVARCHAR (50)   NULL,
    [INVOICE_NO]               NVARCHAR (50)   NULL,
    CONSTRAINT [PK_INSURANCE_REGISTER_ASSET_COVERAGE] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_INSURANCE_REGISTER_ASSET_COVERAGE_INSURANCE_REGISTER_ASSET] FOREIGN KEY ([REGISTER_ASSET_CODE]) REFERENCES [dbo].[INSURANCE_REGISTER_ASSET] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persentase rate depresiasi pada proses pendaftaran periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET_COVERAGE', @level2type = N'COLUMN', @level2name = N'RATE_DEPRECIATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode coverage pada proses pendaftaran periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET_COVERAGE', @level2type = N'COLUMN', @level2name = N'COVERAGE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Periode tahun pada proses pendaftaran periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET_COVERAGE', @level2type = N'COLUMN', @level2name = N'YEAR_PERIODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persentase rate beli awal pada proses pendaftaran periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET_COVERAGE', @level2type = N'COLUMN', @level2name = N'INITIAL_BUY_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai beli awal asuransi  dari maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET_COVERAGE', @level2type = N'COLUMN', @level2name = N'INITIAL_BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persentase rate diskon asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET_COVERAGE', @level2type = N'COLUMN', @level2name = N'INITIAL_DISCOUNT_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai diskon beli asuransi dari maskapai', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET_COVERAGE', @level2type = N'COLUMN', @level2name = N'INITIAL_DISCOUNT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Biaya admin pada proses beli asuransi dari maskapai', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET_COVERAGE', @level2type = N'COLUMN', @level2name = N'INITIAL_ADMIN_FEE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Biaya materai pada proses register asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET_COVERAGE', @level2type = N'COLUMN', @level2name = N'INITIAL_STAMP_FEE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai premi beli asuransi dari maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET_COVERAGE', @level2type = N'COLUMN', @level2name = N'BUY_AMOUNT';

