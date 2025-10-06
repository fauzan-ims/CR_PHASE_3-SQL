CREATE TABLE [dbo].[INSURANCE_REGISTER_EXISTING_ASSET] (
    [ID]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [REGISTER_CODE]      NVARCHAR (50)   NOT NULL,
    [FA_CODE]            NVARCHAR (50)   NOT NULL,
    [SUM_INSURED_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_REGISTER_EXISTING_ASSET_SUM_INSURED_AMOUNT] DEFAULT ((0)) NOT NULL,
    [COVERAGE_CODE]      NVARCHAR (50)   NOT NULL,
    [PREMI_SELL_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_REGISTER_EXISTING_ASSET_TOTAL_PREMI_SELL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]           DATETIME        NOT NULL,
    [CRE_BY]             NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    [MOD_DATE]           DATETIME        NOT NULL,
    [MOD_BY]             NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_INSURANCE_REGISTER_EXISTING_ASSET] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_INSURANCE_REGISTER_EXISTING_ASSET_INSURANCE_REGISTER_EXISTING] FOREIGN KEY ([REGISTER_CODE]) REFERENCES [dbo].[INSURANCE_REGISTER_EXISTING] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING_ASSET', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode register pada proses pendaftaran periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING_ASSET', @level2type = N'COLUMN', @level2name = N'REGISTER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor collateral pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING_ASSET', @level2type = N'COLUMN', @level2name = N'FA_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai yang dicover oleh asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING_ASSET', @level2type = N'COLUMN', @level2name = N'SUM_INSURED_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode coverage pada proses pendaftaran periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING_ASSET', @level2type = N'COLUMN', @level2name = N'COVERAGE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total nilai premi asuransi yang dijual kepada customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING_ASSET', @level2type = N'COLUMN', @level2name = N'PREMI_SELL_AMOUNT';

