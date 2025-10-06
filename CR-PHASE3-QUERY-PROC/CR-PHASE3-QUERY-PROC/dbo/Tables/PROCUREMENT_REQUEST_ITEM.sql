CREATE TABLE [dbo].[PROCUREMENT_REQUEST_ITEM] (
    [ID]                         BIGINT          IDENTITY (1, 1) NOT NULL,
    [PROCUREMENT_REQUEST_CODE]   NVARCHAR (50)   CONSTRAINT [DF_PROCUREMENT_REQUEST_ITEM_PROCUREMENT_REQUEST_CODE] DEFAULT ('') NOT NULL,
    [ITEM_CODE]                  NVARCHAR (50)   CONSTRAINT [DF_PROCUREMENT_REQUEST_ITEM_ITEM_CODE] DEFAULT ('') NOT NULL,
    [ITEM_NAME]                  NVARCHAR (250)  CONSTRAINT [DF_PROCUREMENT_REQUEST_ITEM_ITEM_NAME] DEFAULT ('') NOT NULL,
    [QUANTITY_REQUEST]           INT             CONSTRAINT [DF_PROCUREMENT_REQUEST_ITEM_QUANTITY_REQUEST] DEFAULT ((0)) NOT NULL,
    [APPROVED_QUANTITY]          INT             NOT NULL,
    [TYPE_ASSET_CODE]            NVARCHAR (25)   NULL,
    [UOM_CODE]                   NVARCHAR (50)   NULL,
    [UOM_NAME]                   NVARCHAR (250)  NULL,
    [SPECIFICATION]              NVARCHAR (4000) CONSTRAINT [DF_PROCUREMENT_REQUEST_ITEM_SPECIFICATION] DEFAULT ('') NOT NULL,
    [ITEM_CATEGORY_CODE]         NVARCHAR (50)   NULL,
    [ITEM_CATEGORY_NAME]         NVARCHAR (250)  NULL,
    [ITEM_MERK_CODE]             NVARCHAR (50)   NULL,
    [ITEM_MERK_NAME]             NVARCHAR (250)  NULL,
    [ITEM_MODEL_CODE]            NVARCHAR (50)   NULL,
    [ITEM_MODEL_NAME]            NVARCHAR (250)  NULL,
    [ITEM_TYPE_CODE]             NVARCHAR (50)   NULL,
    [ITEM_TYPE_NAME]             NVARCHAR (250)  NULL,
    [FA_CODE]                    NVARCHAR (50)   NULL,
    [FA_NAME]                    NVARCHAR (250)  NULL,
    [CATEGORY_TYPE]              NVARCHAR (15)   NULL,
    [SPAF_AMOUNT]                DECIMAL (18, 2) NULL,
    [SUBVENTION_AMOUNT]          DECIMAL (18, 2) NULL,
    [REMARK]                     NVARCHAR (4000) NULL,
    [CRE_DATE]                   DATETIME        NOT NULL,
    [CRE_BY]                     NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]                   DATETIME        NOT NULL,
    [MOD_BY]                     NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [IS_BBN]                     NVARCHAR (1)    NULL,
    [BBN_NAME]                   NVARCHAR (250)  NULL,
    [BBN_ADDRESS]                NVARCHAR (4000) NULL,
    [IS_RECOM]                   NVARCHAR (1)    NULL,
    [ASSET_AMOUNT]               DECIMAL (18, 2) NULL,
    [ASSET_DISCOUNT_AMOUNT]      DECIMAL (18, 2) NULL,
    [KAROSERI_AMOUNT]            DECIMAL (18, 2) NULL,
    [KAROSERI_DISCOUNT_AMOUNT]   DECIMAL (18, 2) NULL,
    [ACCESORIES_AMOUNT]          DECIMAL (18, 2) NULL,
    [ACCESORIES_DISCOUNT_AMOUNT] DECIMAL (18, 2) NULL,
    [MOBILIZATION_AMOUNT]        DECIMAL (18, 2) NULL,
    [OTR_AMOUNT]                 DECIMAL (18, 2) NULL,
    [GPS_AMOUNT]                 DECIMAL (18, 2) NULL,
    [BUDGET_AMOUNT]              DECIMAL (18, 2) NULL,
    [BBN_LOCATION]               NVARCHAR (250)  NULL,
    [DELIVER_TO_ADDRESS]         NVARCHAR (4000) NULL,
    [CONDITION]                  NVARCHAR (50)   NULL,
    CONSTRAINT [PK_PROCUREMENT_REQUEST_ITEM] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PROCUREMENT_REQUEST_ITEM_PROCUREMENT_REQUEST] FOREIGN KEY ([PROCUREMENT_REQUEST_CODE]) REFERENCES [dbo].[PROCUREMENT_REQUEST] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [idx_PROCUREMENT_REQUEST_ITEM_22092025]
    ON [dbo].[PROCUREMENT_REQUEST_ITEM]([PROCUREMENT_REQUEST_CODE] ASC)
    INCLUDE([FA_CODE]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PROCUREMENT REQUEST', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'PROCUREMENT_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE ITEM, DIAMBIL DARI MODULE IFINBAM TABLE MASTER ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'ITEM_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA ITEM, DIAMBIL DARI MODULE IFINBAM TABLE MASTER ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'ITEM_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KUANTITAS YANG DIAJUKAN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'QUANTITY_REQUEST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KUANTITAS YANG DISETUJUI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'APPROVED_QUANTITY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'TYPE_ASSET_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE SATUAN, CONTOH UNT, KG', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'UOM_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA SATUAN, CONTOH UNIT, KILOGRAM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'UOM_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SPESIFIKASI ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'SPECIFICATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'ITEM_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'ITEM_CATEGORY_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'ITEM_MERK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'ITEM_MERK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'ITEM_MODEL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'ITEM_MODEL_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'ITEM_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'ITEM_TYPE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KETERANGAN TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT_REQUEST_ITEM', @level2type = N'COLUMN', @level2name = N'REMARK';

