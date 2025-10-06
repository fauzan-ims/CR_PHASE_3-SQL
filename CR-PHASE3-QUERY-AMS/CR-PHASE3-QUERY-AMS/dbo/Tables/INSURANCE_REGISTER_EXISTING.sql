CREATE TABLE [dbo].[INSURANCE_REGISTER_EXISTING] (
    [CODE]                     NVARCHAR (50)   NOT NULL,
    [REGISTER_NO]              NVARCHAR (50)   NOT NULL,
    [POLICY_CODE]              NVARCHAR (50)   NULL,
    [BRANCH_CODE]              NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]              NVARCHAR (250)  NOT NULL,
    [SOURCE_TYPE]              NVARCHAR (20)   NULL,
    [POLICY_NAME]              NVARCHAR (250)  NOT NULL,
    [POLICY_QQ_NAME]           NVARCHAR (250)  NOT NULL,
    [REGISTER_STATUS]          NVARCHAR (10)   CONSTRAINT [DF_INSURANCE_REGISTER_EXISTING_REGISTER_STATUS] DEFAULT (N'HOLD') NOT NULL,
    [POLICY_OBJECT_NAME]       NVARCHAR (250)  NOT NULL,
    [SUM_INSURED_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_EXISTING_SUM_INSURED_1] DEFAULT ((0)) NOT NULL,
    [INSURANCE_CODE]           NVARCHAR (50)   CONSTRAINT [DF_INSURANCE_EXISTING_INSURANCE_CODE_1] DEFAULT ((0)) NOT NULL,
    [INSURANCE_TYPE]           NVARCHAR (10)   NOT NULL,
    [COLLATERAL_TYPE]          NVARCHAR (10)   NULL,
    [COLLATERAL_YEAR]          NVARCHAR (4)    NULL,
    [COLLATERAL_CATEGORY_CODE] NVARCHAR (50)   CONSTRAINT [DF_INSURANCE_REGISTER_EXISTING_COLLATERAL_CATEGORY_CODE] DEFAULT (N'VHCL') NULL,
    [DEPRECIATION_CODE]        NVARCHAR (50)   CONSTRAINT [DF_INSURANCE_EXISTING_DEPRECIATION_CODE] DEFAULT ((0)) NULL,
    [OCCUPATION_CODE]          NVARCHAR (50)   CONSTRAINT [DF_INSURANCE_EXISTING_OCCUPATION_CODE] DEFAULT ((0)) NULL,
    [FA_CODE]                  NVARCHAR (50)   NULL,
    [CURRENCY_CODE]            NVARCHAR (3)    NOT NULL,
    [POLICY_NO]                NVARCHAR (50)   NULL,
    [POLICY_EFF_DATE]          DATETIME        NULL,
    [POLICY_EXP_DATE]          DATETIME        NULL,
    [FILE_NAME]                NVARCHAR (250)  CONSTRAINT [DF_INSURANCE_EXISTING_FILE_NAME_1] DEFAULT (N'') NULL,
    [PATHS]                    NVARCHAR (250)  CONSTRAINT [DF_INSURANCE_EXISTING_PATHS_1] DEFAULT (N'') NULL,
    [REGION_CODE]              NVARCHAR (50)   NULL,
    [FROM_YEAR]                NVARCHAR (1)    NOT NULL,
    [TO_YEAR]                  NVARCHAR (1)    NOT NULL,
    [TOTAL_PREMI_SELL_AMOUNT]  DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_EXISTING_TOTAL_PREMI_SELL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [TOTAL_PREMI_BUY_AMOUNT]   DECIMAL (18, 2) CONSTRAINT [DF_INSURANCE_EXISTING_TOTAL_PREMI_BUY_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_INSURANCE_REGISTER_EXISTING] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_INSURANCE_REGISTER_EXISTING_ASSET] FOREIGN KEY ([FA_CODE]) REFERENCES [dbo].[ASSET] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor register pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'REGISTER_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor polis asuransi pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'POLICY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama yang dicover asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'POLICY_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama yang dibebankan oleh asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'POLICY_QQ_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses pendaftaran asuransi existing tersebut - HOLD, menginformasikan bahwa data tersebut belum diproses - POST, menginformasikan bahwa data tersebut sudah dilakukan proses posting - CANCEL, menginformasikan bahwa data tersebut sudah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'REGISTER_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama objek yang dicover oleh asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'POLICY_OBJECT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai yang dicover oleh asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'SUM_INSURED_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode asuransi pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'INSURANCE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe asuransi pada proses pendaftaran asuransi existing tersebut - LIFE, menginformasikan bahwa asuransi tersebut merupakan asuransi jiwa - NON LIFE, menginformasikan bahwa asuransi tersebut bukan merupakan asuransi jiwa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'INSURANCE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe collateral pada proses pendaftaran asuransi existing tersebut - VHCL, menginformasikan bahwa collateral tersebut bertipe kendaraan - MCHN, menginformasikan bahwa collateral tersebut bertipe mesin - HE, menginformasikan bahwa collateral tersebut bertipe alat berat - PROP, menginformasikan bahwa collateral tersebut bertipe property - OTHER, menginformasikan bahwa collateral tersebut bertipe lain lain', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'COLLATERAL_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe collateral pada proses pendaftaran asuransi existing tersebut - VHCL, menginformasikan bahwa collateral tersebut bertipe kendaraan - MCHN, menginformasikan bahwa collateral tersebut bertipe mesin - HE, menginformasikan bahwa collateral tersebut bertipe alat berat - PROP, menginformasikan bahwa collateral tersebut bertipe property - OTHER, menginformasikan bahwa collateral tersebut bertipe lain lain', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'COLLATERAL_YEAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kategori collateral pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'COLLATERAL_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode depresiasi pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'DEPRECIATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode okupasi pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'OCCUPATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor collateral pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'FA_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor polis asuransi pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'POLICY_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal mulai berlakunya polis asuransi pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'POLICY_EFF_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kadaluwarsa polis asuransi pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'POLICY_EXP_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama file yang diupload pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama folder file yang diupload pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'PATHS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode wilayah asuransi pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'REGION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah tahun asuransi pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'FROM_YEAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas tahun asuransi pada proses pendaftaran asuransi existing tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'TO_YEAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total nilai premi asuransi yang dijual kepada customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'TOTAL_PREMI_SELL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai total beli asuransi dari maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INSURANCE_REGISTER_EXISTING', @level2type = N'COLUMN', @level2name = N'TOTAL_PREMI_BUY_AMOUNT';

