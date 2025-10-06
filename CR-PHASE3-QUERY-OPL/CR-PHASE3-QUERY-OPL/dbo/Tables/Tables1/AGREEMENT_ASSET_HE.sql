CREATE TABLE [dbo].[AGREEMENT_ASSET_HE] (
    [ASSET_NO]            NVARCHAR (50)   NOT NULL,
    [HE_CATEGORY_CODE]    NVARCHAR (50)   NULL,
    [HE_SUBCATEGORY_CODE] NVARCHAR (50)   NULL,
    [HE_MERK_CODE]        NVARCHAR (50)   NULL,
    [HE_MODEL_CODE]       NVARCHAR (50)   NULL,
    [HE_TYPE_CODE]        NVARCHAR (50)   NULL,
    [HE_UNIT_CODE]        NVARCHAR (50)   NULL,
    [COLOUR]              NVARCHAR (250)  NULL,
    [REMARKS]             NVARCHAR (4000) NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    CONSTRAINT [FK_AGREEMENT_ASSET_HE_AGREEMENT_ASSET] FOREIGN KEY ([ASSET_NO]) REFERENCES [dbo].[AGREEMENT_ASSET] ([ASSET_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_HE', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kategori atas heavy equipment tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_HE', @level2type = N'COLUMN', @level2name = N'HE_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode sub kategori atas heavy equipment tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_HE', @level2type = N'COLUMN', @level2name = N'HE_SUBCATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode merk atas heavy equipment tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_HE', @level2type = N'COLUMN', @level2name = N'HE_MERK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode model atas heavy equipment tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_HE', @level2type = N'COLUMN', @level2name = N'HE_MODEL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode tipe atas heavy equipment tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_HE', @level2type = N'COLUMN', @level2name = N'HE_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode unit atas heavy equipment tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_HE', @level2type = N'COLUMN', @level2name = N'HE_UNIT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Warna atas heavy equipment tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_HE', @level2type = N'COLUMN', @level2name = N'COLOUR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan terkait dengan heavy equipment tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_HE', @level2type = N'COLUMN', @level2name = N'REMARKS';

