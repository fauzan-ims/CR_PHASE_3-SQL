CREATE TABLE [dbo].[QUOTATION_REVIEW_DETAIL] (
    [ID]                         BIGINT          IDENTITY (1, 1) NOT NULL,
    [QUOTATION_REVIEW_CODE]      NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [QUOTATION_REVIEW_DATE]      DATETIME        NULL,
    [REFF_NO]                    NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [BRANCH_CODE]                NVARCHAR (50)   CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_DETAIL_BRANCH_CODE] DEFAULT ('') NOT NULL,
    [BRANCH_NAME]                NVARCHAR (250)  CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_DETAIL_BRANCH_NAME] DEFAULT ('') NOT NULL,
    [CURRENCY_CODE]              NVARCHAR (20)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CURRENCY_NAME]              NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [PAYMENT_METHODE_CODE]       NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ITEM_CODE]                  NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ITEM_NAME]                  NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TYPE_ASSET_CODE]            NVARCHAR (25)   NULL,
    [ITEM_CATEGORY_CODE]         NVARCHAR (50)   NULL,
    [ITEM_CATEGORY_NAME]         NVARCHAR (250)  NULL,
    [ITEM_MERK_CODE]             NVARCHAR (50)   NULL,
    [ITEM_MERK_NAME]             NVARCHAR (250)  NULL,
    [ITEM_MODEL_CODE]            NVARCHAR (50)   NULL,
    [ITEM_MODEL_NAME]            NVARCHAR (250)  NULL,
    [ITEM_TYPE_CODE]             NVARCHAR (50)   NULL,
    [ITEM_TYPE_NAME]             NVARCHAR (250)  NULL,
    [SUPPLIER_CODE]              NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SUPPLIER_NAME]              NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SUPPLIER_ADDRESS]           NVARCHAR (4000) NULL,
    [TAX_CODE]                   NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TAX_NAME]                   NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [PPN_PCT]                    DECIMAL (9, 6)  NOT NULL,
    [PPH_PCT]                    DECIMAL (9, 6)  NOT NULL,
    [WARRANTY_MONTH]             INT             NOT NULL,
    [WARRANTY_PART_MONTH]        INT             NULL,
    [QUANTITY]                   INT             NULL,
    [APPROVED_QUANTITY]          INT             NULL,
    [UOM_CODE]                   NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [UOM_NAME]                   NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PRICE_AMOUNT]               DECIMAL (18, 2) NULL,
    [DISCOUNT_AMOUNT]            DECIMAL (18, 2) NULL,
    [REQUESTOR_CODE]             NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [REQUESTOR_NAME]             NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [UNIT_AVAILABLE_STATUS]      NVARCHAR (10)   NULL,
    [INDENT_DAYS]                INT             NULL,
    [OFFERING]                   NVARCHAR (4000) NULL,
    [UNIT_FROM]                  NVARCHAR (25)   NULL,
    [SPESIFICATION]              NVARCHAR (4000) NULL,
    [REMARK]                     NVARCHAR (4000) COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_DETAIL_REMARK] DEFAULT ('') NULL,
    [CRE_DATE]                   DATETIME        NOT NULL,
    [CRE_BY]                     NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_DETAIL_CRE_BY] DEFAULT ('') NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_DETAIL_CRE_IP_ADDRESS] DEFAULT ('') NOT NULL,
    [MOD_DATE]                   DATETIME        NOT NULL,
    [MOD_BY]                     NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_DETAIL_MOD_BY] DEFAULT ('') NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_PROCUREMENT_QUOTATION_REVIEW_DETAIL_MOD_IP_ADDRESS] DEFAULT ('') NOT NULL,
    [EXPIRED_DATE]               DATETIME        NULL,
    [TOTAL_AMOUNT]               DECIMAL (18, 2) NULL,
    [NETT_PRICE]                 DECIMAL (18, 2) NULL,
    [SUPPLIER_NPWP]              NVARCHAR (20)   NULL,
    [TYPE]                       NVARCHAR (50)   NULL,
    [ASSET_AMOUNT]               DECIMAL (18, 2) NULL,
    [ASSET_DISCOUNT_AMOUNT]      DECIMAL (18, 2) NULL,
    [KAROSERI_AMOUNT]            DECIMAL (18, 2) NULL,
    [KAROSERI_DISCOUNT_AMOUNT]   DECIMAL (18, 2) NULL,
    [ACCESORIES_AMOUNT]          DECIMAL (18, 2) NULL,
    [ACCESORIES_DISCOUNT_AMOUNT] DECIMAL (18, 2) NULL,
    [MOBILIZATION_AMOUNT]        DECIMAL (18, 2) NULL,
    [APPLICATION_NO]             NVARCHAR (50)   NULL,
    [OTR_AMOUNT]                 DECIMAL (18, 2) NULL,
    [GPS_AMOUNT]                 DECIMAL (18, 2) NULL,
    [BUDGET_AMOUNT]              DECIMAL (18, 2) NULL,
    [SUPPLIER_NITKU]             NVARCHAR (50)   NULL,
    [SUPPLIER_NPWP_PUSAT]        NVARCHAR (50)   NULL,
    [BBN_NAME]                   NVARCHAR (250)  NULL,
    [BBN_LOCATION]               NVARCHAR (250)  NULL,
    [BBN_ADDRESS]                NVARCHAR (4000) NULL,
    [DELIVER_TO_ADDRESS]         NVARCHAR (4000) NULL,
    CONSTRAINT [PK_PROCUREMENT_QUOTATION_REVIEW_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE QUOTATION REVIEW', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'QUOTATION_REVIEW_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'QUOTATION_REVIEW_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT  USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'REFF_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE BRANCH, DIAMBIL DARI MODULE IFINSYS TABLE SYS BRANCH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA BRANCH, DIAMBIL DARI MODULE IFINSYS TABLE SYS BRANCH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE MATA UANG, DIAMBIL DARI MODULE IFINSYS TABLE SYS CURRENCY', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA MATA UANG, DIAMBIL DARI MODULE IFINSYS TABLE SYS CURRENCY', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'CURRENCY_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'PAYMENT_METHODE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE ITEM, DIAMBIL DARI MODULE IFINBAM TABLE MASTER ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'ITEM_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA ITEM, DIAMBIL DARI MODULE IFINBAM TABLE MASTER ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'ITEM_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'TYPE_ASSET_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'ITEM_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'ITEM_CATEGORY_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'ITEM_MERK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'ITEM_MERK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'ITEM_MODEL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'ITEM_MODEL_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'ITEM_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'ITEM_TYPE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE SUPLIER, DIAMBIL DARI MODULE IFINBAM TABLE MASTER VENDOR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'SUPPLIER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA SUPLIER, DIAMBIL DARI MODULE IFINBAM TABLE MASTER VENDOR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'SUPPLIER_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ALAMAT SUPPLIER, DIAMBIL DARI MODULE IFINBAM TABLE MASTER VENDOR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'SUPPLIER_ADDRESS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PAJAK, DIAMBIL DARI IFINBAM TABLE MASTET TAX', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'TAX_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA PAJAK, DIAMBIL DARI IFINBAM TABLE MASTET TAX', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'TAX_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PERSENTASE PPN TRANSAKSI, DIAMBIL DARI MODULE IFIBAM TABLE MASTER TAX', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'PPN_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PERSENTASE PPH TRANSAKSI, DIAMBIL DARI MODULE IFIBAM TABLE MASTER TAX', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'PPH_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'JUMLAH BULAN GARANSI UNIT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'WARRANTY_MONTH';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GARANSI MESIN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'WARRANTY_PART_MONTH';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'JUMLAH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'QUANTITY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'JUMLAH YANG DISEETUJUI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'APPROVED_QUANTITY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE UNIT CONTOH UNT, KG', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'UOM_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA UNIT, CONTOH UNIT, KILOGRAM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'UOM_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'JUMLAH HARGA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'PRICE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'JUMLAH DISKON', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'DISCOUNT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PEMOHON, DIAMBIL DARI MODULE IFINSYS TABLE SYS_EMPLOYEE_MAIN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'REQUESTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA PEMOHON, DIAMBIL DARI MODULE IFINSYS TABLE SYS_EMPLOYEE_MAIN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'REQUESTOR_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ASAL UNIT, RADIO BUTTON VALUE RENT & BUY', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'UNIT_FROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SPESIFIKASI ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'SPESIFICATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'REMARK TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUOTATION_REVIEW_DETAIL', @level2type = N'COLUMN', @level2name = N'REMARK';

