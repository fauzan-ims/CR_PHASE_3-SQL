CREATE TABLE [dbo].[APPLICATION_ASSET_VEHICLE] (
    [ASSET_NO]                 NVARCHAR (50)   NOT NULL,
    [VEHICLE_CATEGORY_CODE]    NVARCHAR (50)   NULL,
    [VEHICLE_SUBCATEGORY_CODE] NVARCHAR (50)   NULL,
    [VEHICLE_MERK_CODE]        NVARCHAR (50)   NULL,
    [VEHICLE_MODEL_CODE]       NVARCHAR (50)   NULL,
    [VEHICLE_TYPE_CODE]        NVARCHAR (50)   NULL,
    [VEHICLE_UNIT_CODE]        NVARCHAR (50)   NULL,
    [COLOUR]                   NVARCHAR (250)  NULL,
    [TRANSMISI]                NVARCHAR (250)  NULL,
    [REMARKS]                  NVARCHAR (4000) NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_APPLICATION_ASSET_VEHICLE] PRIMARY KEY CLUSTERED ([ASSET_NO] ASC),
    CONSTRAINT [FK_APPLICATION_ASSET_VEHICLE_APPLICATION_ASSET] FOREIGN KEY ([ASSET_NO]) REFERENCES [dbo].[APPLICATION_ASSET] ([ASSET_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_VEHICLE', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kategori atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_VEHICLE', @level2type = N'COLUMN', @level2name = N'VEHICLE_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode sub kategori atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_VEHICLE', @level2type = N'COLUMN', @level2name = N'VEHICLE_SUBCATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode merk atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_VEHICLE', @level2type = N'COLUMN', @level2name = N'VEHICLE_MERK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode model atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_VEHICLE', @level2type = N'COLUMN', @level2name = N'VEHICLE_MODEL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode type atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_VEHICLE', @level2type = N'COLUMN', @level2name = N'VEHICLE_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode unit atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_VEHICLE', @level2type = N'COLUMN', @level2name = N'VEHICLE_UNIT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Warna atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_VEHICLE', @level2type = N'COLUMN', @level2name = N'COLOUR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis transmisi atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_VEHICLE', @level2type = N'COLUMN', @level2name = N'TRANSMISI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan terkait dengan vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET_VEHICLE', @level2type = N'COLUMN', @level2name = N'REMARKS';

