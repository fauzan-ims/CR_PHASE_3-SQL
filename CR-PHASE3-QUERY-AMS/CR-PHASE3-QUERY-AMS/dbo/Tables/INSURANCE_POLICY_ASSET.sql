CREATE TABLE [dbo].[INSURANCE_POLICY_ASSET] (
    [CODE]                     NVARCHAR (50)   NOT NULL,
    [POLICY_CODE]              NVARCHAR (50)   NOT NULL,
    [FA_CODE]                  NVARCHAR (50)   NOT NULL,
    [SUM_INSURED_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_POLICY_ASSET_SUM_INSURED_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DEPRECIATION_CODE]        NVARCHAR (50)   NULL,
    [COLLATERAL_TYPE]          NVARCHAR (10)   NULL,
    [COLLATERAL_CATEGORY_CODE] NVARCHAR (50)   NULL,
    [OCCUPATION_CODE]          NVARCHAR (50)   NULL,
    [REGION_CODE]              NVARCHAR (50)   NULL,
    [COLLATERAL_YEAR]          NVARCHAR (4)    NULL,
    [IS_AUTHORIZED_WORKSHOP]   NVARCHAR (1)    CONSTRAINT [DF_INSURANCE_POLICY_ASSET_IS_AUTHORIZED_WORKSHOP] DEFAULT ((0)) NOT NULL,
    [IS_COMMERCIAL]            NVARCHAR (1)    CONSTRAINT [DF_INSURANCE_POLICY_ASSET_IS_COMMERCIAL] DEFAULT ((0)) NOT NULL,
    [STATUS_ASSET]             NVARCHAR (10)   NULL,
    [INSERT_TYPE]              NVARCHAR (20)   NULL,
    [SPPA_CODE]                NVARCHAR (50)   NULL,
    [INVOICE_CODE]             NVARCHAR (50)   NULL,
    [ACCESSORIES]              NVARCHAR (4000) NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_INSURANCE_POLICY_ASSET] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_INSURANCE_POLICY_ASSET_INSURANCE_POLICY_MAIN] FOREIGN KEY ([POLICY_CODE]) REFERENCES [dbo].[INSURANCE_POLICY_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IDX_INSURANCE_POLICY_ASSET_POLICY_CODE]
    ON [dbo].[INSURANCE_POLICY_ASSET]([POLICY_CODE] ASC)
    INCLUDE([FA_CODE], [SUM_INSURED_AMOUNT], [DEPRECIATION_CODE], [COLLATERAL_TYPE], [COLLATERAL_CATEGORY_CODE], [OCCUPATION_CODE], [REGION_CODE], [COLLATERAL_YEAR], [IS_AUTHORIZED_WORKSHOP], [IS_COMMERCIAL], [STATUS_ASSET], [INSERT_TYPE], [SPPA_CODE], [INVOICE_CODE], [ACCESSORIES], [CRE_DATE], [CRE_BY], [CRE_IP_ADDRESS], [MOD_DATE], [MOD_BY], [MOD_IP_ADDRESS]);


GO
CREATE NONCLUSTERED INDEX [INSURANCE_POLICY_ASSET_CRE_BY_POLICY_CODE]
    ON [dbo].[INSURANCE_POLICY_ASSET]([CRE_BY] ASC)
    INCLUDE([POLICY_CODE]);


GO
CREATE NONCLUSTERED INDEX [IDX_INSURANCE_POLICY_ASSET_20240304]
    ON [dbo].[INSURANCE_POLICY_ASSET]([FA_CODE] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_ASSET', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode register pada proses pendaftaran periode asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_ASSET', @level2type = N'COLUMN', @level2name = N'POLICY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor collateral pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_ASSET', @level2type = N'COLUMN', @level2name = N'FA_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai yang dicover oleh asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_ASSET', @level2type = N'COLUMN', @level2name = N'SUM_INSURED_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode depresiasi pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_ASSET', @level2type = N'COLUMN', @level2name = N'DEPRECIATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe collateral pada proses pendaftaran asuransi tersebut - VHCL, menginformasikan bahwa collateral tersebut bertipe kendaraan - MCHN, menginformasikan bahwa collateral tersebut bertipe mesin - HE, menginformasikan bahwa collateral tersebut bertipe alat berat - PROP, menginformasikan bahwa collateral tersebut bertipe property - OTHER, menginformasikan bahwa collateral tersebut bertipe lain lain', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_ASSET', @level2type = N'COLUMN', @level2name = N'COLLATERAL_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kategori collateral pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_ASSET', @level2type = N'COLUMN', @level2name = N'COLLATERAL_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode okupasi pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_ASSET', @level2type = N'COLUMN', @level2name = N'OCCUPATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode wilayah asuransi pada proses pendaftaran asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_ASSET', @level2type = N'COLUMN', @level2name = N'REGION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah unit tersebut diservis pada bengkel resmi?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_ASSET', @level2type = N'COLUMN', @level2name = N'IS_AUTHORIZED_WORKSHOP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah collateral yang didaftarkan pada asuransi tersebut bertipe commercial?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_POLICY_ASSET', @level2type = N'COLUMN', @level2name = N'IS_COMMERCIAL';

