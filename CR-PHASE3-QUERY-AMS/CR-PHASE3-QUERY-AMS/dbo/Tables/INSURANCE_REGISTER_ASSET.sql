CREATE TABLE [dbo].[INSURANCE_REGISTER_ASSET] (
    [CODE]                     NVARCHAR (50)   NOT NULL,
    [REGISTER_CODE]            NVARCHAR (50)   NOT NULL,
    [FA_CODE]                  NVARCHAR (50)   NOT NULL,
    [SUM_INSURED_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_REGISTER_ASSET_SUM_INSURED_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DEPRECIATION_CODE]        NVARCHAR (50)   NULL,
    [COLLATERAL_TYPE]          NVARCHAR (10)   NULL,
    [COLLATERAL_CATEGORY_CODE] NVARCHAR (50)   NULL,
    [OCCUPATION_CODE]          NVARCHAR (50)   NULL,
    [REGION_CODE]              NVARCHAR (50)   NULL,
    [COLLATERAL_YEAR]          NVARCHAR (4)    NULL,
    [IS_AUTHORIZED_WORKSHOP]   NVARCHAR (1)    CONSTRAINT [DF_INSURANCE_REGISTER_ASSET_IS_AUTHORIZED_WORKSHOP] DEFAULT ((0)) NOT NULL,
    [IS_COMMERCIAL]            NVARCHAR (1)    CONSTRAINT [DF_INSURANCE_REGISTER_ASSET_IS_COMMERCIAL] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [ACCESSORIES]              NVARCHAR (4000) NULL,
    [INSERT_TYPE]              NVARCHAR (20)   NULL,
    [IS_BUDGET]                NVARCHAR (1)    NULL,
    [IS_MANUAL]                NVARCHAR (1)    NULL,
    CONSTRAINT [PK_INSURANCE_REGISTER_ASSET] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_INSURANCE_REGISTER_ASSET_INSURANCE_REGISTER] FOREIGN KEY ([REGISTER_CODE]) REFERENCES [dbo].[INSURANCE_REGISTER] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode register pada proses pendaftaran periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET', @level2type = N'COLUMN', @level2name = N'REGISTER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor collateral pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET', @level2type = N'COLUMN', @level2name = N'FA_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai yang dicover oleh asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET', @level2type = N'COLUMN', @level2name = N'SUM_INSURED_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode depresiasi pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET', @level2type = N'COLUMN', @level2name = N'DEPRECIATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe collateral pada proses pendaftaran asuransi tersebut - VHCL, menginformasikan bahwa collateral tersebut bertipe kendaraan - MCHN, menginformasikan bahwa collateral tersebut bertipe mesin - HE, menginformasikan bahwa collateral tersebut bertipe alat berat - PROP, menginformasikan bahwa collateral tersebut bertipe property - OTHER, menginformasikan bahwa collateral tersebut bertipe lain lain', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET', @level2type = N'COLUMN', @level2name = N'COLLATERAL_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kategori collateral pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET', @level2type = N'COLUMN', @level2name = N'COLLATERAL_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode okupasi pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET', @level2type = N'COLUMN', @level2name = N'OCCUPATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode wilayah asuransi pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET', @level2type = N'COLUMN', @level2name = N'REGION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah unit tersebut diservis pada bengkel resmi?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET', @level2type = N'COLUMN', @level2name = N'IS_AUTHORIZED_WORKSHOP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah collateral yang didaftarkan pada asuransi tersebut bertipe commercial?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_ASSET', @level2type = N'COLUMN', @level2name = N'IS_COMMERCIAL';

