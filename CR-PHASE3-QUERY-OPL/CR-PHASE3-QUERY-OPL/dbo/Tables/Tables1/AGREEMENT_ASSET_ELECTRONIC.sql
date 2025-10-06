CREATE TABLE [dbo].[AGREEMENT_ASSET_ELECTRONIC] (
    [ASSET_NO]                    NVARCHAR (50)   NOT NULL,
    [ELECTRONIC_CATEGORY_CODE]    NVARCHAR (50)   NULL,
    [ELECTRONIC_SUBCATEGORY_CODE] NVARCHAR (50)   NULL,
    [ELECTRONIC_MERK_CODE]        NVARCHAR (50)   NULL,
    [ELECTRONIC_MODEL_CODE]       NVARCHAR (50)   NULL,
    [ELECTRONIC_UNIT_CODE]        NVARCHAR (50)   NULL,
    [COLOUR]                      NVARCHAR (250)  NULL,
    [REMARKS]                     NVARCHAR (4000) NULL,
    [CRE_DATE]                    DATETIME        NOT NULL,
    [CRE_BY]                      NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                    DATETIME        NOT NULL,
    [MOD_BY]                      NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_AGREEMENT_ASSET_ELECTRONIC] PRIMARY KEY CLUSTERED ([ASSET_NO] ASC),
    CONSTRAINT [FK_AGREEMENT_ASSET_ELECTRONIC_AGREEMENT_ASSET] FOREIGN KEY ([ASSET_NO]) REFERENCES [dbo].[AGREEMENT_ASSET] ([ASSET_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_ELECTRONIC', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kategori atas asset elektronik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_ELECTRONIC', @level2type = N'COLUMN', @level2name = N'ELECTRONIC_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode sub kategori atas asset elektronik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_ELECTRONIC', @level2type = N'COLUMN', @level2name = N'ELECTRONIC_SUBCATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode merk atas asset elektronik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_ELECTRONIC', @level2type = N'COLUMN', @level2name = N'ELECTRONIC_MERK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode model atas asset elektronik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_ELECTRONIC', @level2type = N'COLUMN', @level2name = N'ELECTRONIC_MODEL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode unit atas asset elektronik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_ELECTRONIC', @level2type = N'COLUMN', @level2name = N'ELECTRONIC_UNIT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Warna atas asset elektronik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_ELECTRONIC', @level2type = N'COLUMN', @level2name = N'COLOUR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan terkait dengan asset elektronik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET_ELECTRONIC', @level2type = N'COLUMN', @level2name = N'REMARKS';

