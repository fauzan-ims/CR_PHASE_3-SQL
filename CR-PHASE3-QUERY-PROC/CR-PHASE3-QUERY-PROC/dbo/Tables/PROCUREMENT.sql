CREATE TABLE [dbo].[PROCUREMENT] (
    [CODE]                        NVARCHAR (50)   NOT NULL,
    [COMPANY_CODE]                NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PROCUREMENT_REQUEST_ITEM_ID] BIGINT          CONSTRAINT [DF_PROCUREMENT_PROCUREMENT_REQUEST_ITEM_ID] DEFAULT ((0)) NOT NULL,
    [PROCUREMENT_REQUEST_CODE]    NVARCHAR (50)   CONSTRAINT [DF_PROCUREMENT_PROCUREMENT_REQUEST_CODE] DEFAULT ('') NOT NULL,
    [PROCUREMENT_REQUEST_DATE]    DATETIME        CONSTRAINT [DF_PROCUREMENT_PROCUREMENT_REQUEST_CODE1] DEFAULT ('') NOT NULL,
    [BRANCH_CODE]                 NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_Table_1_ITEM_CODE1] DEFAULT ('') NULL,
    [BRANCH_NAME]                 NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_Table_1_ITEM_NAME1] DEFAULT ('') NULL,
    [ITEM_CODE]                   NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_ITEM_CODE] DEFAULT ('') NOT NULL,
    [ITEM_NAME]                   NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_ITEM_NAME] DEFAULT ('') NOT NULL,
    [ITEM_GROUP_CODE]             NVARCHAR (50)   NULL,
    [TYPE_CODE]                   NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_Table_1_ITEM_CODE1_1] DEFAULT ('') NOT NULL,
    [TYPE_NAME]                   NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TYPE_ASSET_CODE]             NVARCHAR (25)   NULL,
    [ITEM_CATEGORY_CODE]          NVARCHAR (50)   NULL,
    [ITEM_CATEGORY_NAME]          NVARCHAR (250)  NULL,
    [ITEM_MERK_CODE]              NVARCHAR (50)   NULL,
    [ITEM_MERK_NAME]              NVARCHAR (250)  NULL,
    [ITEM_MODEL_CODE]             NVARCHAR (50)   NULL,
    [ITEM_MODEL_NAME]             NVARCHAR (250)  NULL,
    [ITEM_TYPE_CODE]              NVARCHAR (50)   NULL,
    [ITEM_TYPE_NAME]              NVARCHAR (250)  NULL,
    [QUANTITY_REQUEST]            INT             CONSTRAINT [DF_PROCUREMENT_QUANTITY_REQUEST] DEFAULT ((0)) NOT NULL,
    [APPROVED_QUANTITY]           INT             NOT NULL,
    [SPECIFICATION]               NVARCHAR (4000) COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_SPECIFICATION] DEFAULT ('') NOT NULL,
    [REMARK]                      NVARCHAR (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [NEW_PURCHASE]                NVARCHAR (20)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_TRANSACTION_TYPE] DEFAULT ('') NOT NULL,
    [PURCHASE_TYPE_CODE]          NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_PURCHASE_TYPE] DEFAULT ('') NULL,
    [PURCHASE_TYPE_NAME]          NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [UNIT_FROM]                   NVARCHAR (25)   NULL,
    [QUANTITY_PURCHASE]           INT             CONSTRAINT [DF_Table_1_QUANTITY_REQUEST1] DEFAULT ((0)) NOT NULL,
    [STATUS]                      NVARCHAR (20)   CONSTRAINT [DF_PROCUREMENT_STATUS] DEFAULT ('') NOT NULL,
    [REQUESTOR_CODE]              NVARCHAR (50)   NULL,
    [REQUESTOR_NAME]              NVARCHAR (250)  NULL,
    [SPAF_AMOUNT]                 DECIMAL (18, 2) NULL,
    [SUBVENTION_AMOUNT]           DECIMAL (18, 2) NULL,
    [CRE_DATE]                    DATETIME        NOT NULL,
    [CRE_BY]                      NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]                    DATETIME        NOT NULL,
    [MOD_BY]                      NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ASSET_AMOUNT]                DECIMAL (18, 2) NULL,
    [ASSET_DISCOUNT_AMOUNT]       DECIMAL (18, 2) NULL,
    [KAROSERI_AMOUNT]             DECIMAL (18, 2) NULL,
    [KAROSERI_DISCOUNT_AMOUNT]    DECIMAL (18, 2) NULL,
    [ACCESORIES_AMOUNT]           DECIMAL (18, 2) NULL,
    [ACCESORIES_DISCOUNT_AMOUNT]  DECIMAL (18, 2) NULL,
    [MOBILIZATION_AMOUNT]         DECIMAL (18, 2) NULL,
    [APPLICATION_NO]              NVARCHAR (50)   NULL,
    [OTR_AMOUNT]                  DECIMAL (18, 2) NULL,
    [GPS_AMOUNT]                  DECIMAL (18, 2) NULL,
    [BUDGET_AMOUNT]               DECIMAL (18, 2) NULL,
    [BBN_NAME]                    NVARCHAR (250)  NULL,
    [BBN_LOCATION]                NVARCHAR (250)  NULL,
    [BBN_ADDRESS]                 NVARCHAR (4000) NULL,
    [DELIVER_TO_ADDRESS]          NVARCHAR (4000) NULL,
    CONSTRAINT [PK_PROCUREMENT] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_PROCUREMENT_PROCUREMENT_REQUEST_CODE]
    ON [dbo].[PROCUREMENT]([PROCUREMENT_REQUEST_CODE] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_UNIT_FROM_20241219]
    ON [dbo].[PROCUREMENT]([UNIT_FROM] ASC)
    INCLUDE([PROCUREMENT_REQUEST_CODE]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PERUSAHAAN (DSF)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'COMPANY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID PROCURENMENT_REQUEST', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'PROCUREMENT_REQUEST_ITEM_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PROCURMENT REQUEST', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'PROCUREMENT_REQUEST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'PROCUREMENT_REQUEST_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE CABANG, DIAMBIL DARI MODULE IFINSYS TABLE SYS BRANCH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA CABANG, DIAMBIL DARI MODULE IFINSYS TABLE SYS BRANCH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'ITEM_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'ITEM_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE GRUP ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'ITEM_GROUP_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'TYPE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'TYPE_ASSET_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'ITEM_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'ITEM_CATEGORY_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'ITEM_MERK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'ITEM_MERK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'ITEM_MODEL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'ITEM_MODEL_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TIPE ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'ITEM_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA TIPE ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'ITEM_TYPE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KUANTITAS YANG DI AJUKAN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'QUANTITY_REQUEST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KUANTITAS YANG DISETUJUI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'APPROVED_QUANTITY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SPESIFIKASI ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'SPECIFICATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KETERANGAN TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'REMARK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'NEW_PURCHASE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TIPE PEMBELIAN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'PURCHASE_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA TIPE PEMBELIAN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'PURCHASE_TYPE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ASAL UNIT, RADIO BUTTON VALUE RENT & BUY', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'UNIT_FROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'JUMLAH PEMBELIAN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'QUANTITY_PURCHASE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'STATUS TRANSAKSI, DDL VALUE NEW, CANCEL, POST', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROCUREMENT', @level2type = N'COLUMN', @level2name = N'STATUS';

