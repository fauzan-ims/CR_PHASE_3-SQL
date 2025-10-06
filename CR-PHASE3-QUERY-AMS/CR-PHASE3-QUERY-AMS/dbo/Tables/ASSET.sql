CREATE TABLE [dbo].[ASSET] (
    [CODE]                               NVARCHAR (50)   NOT NULL,
    [COMPANY_CODE]                       NVARCHAR (50)   NOT NULL,
    [ITEM_CODE]                          NVARCHAR (50)   CONSTRAINT [DF_ASSET_ITEM_CODE] DEFAULT ('') NOT NULL,
    [ITEM_NAME]                          NVARCHAR (250)  CONSTRAINT [DF_ASSET_ITEM_NAME] DEFAULT ('') NOT NULL,
    [ITEM_GROUP_CODE]                    NVARCHAR (50)   NULL,
    [CONDITION]                          NVARCHAR (50)   NULL,
    [BARCODE]                            NVARCHAR (50)   CONSTRAINT [DF_ASSET_BARCODE] DEFAULT ('') NULL,
    [STATUS]                             NVARCHAR (50)   CONSTRAINT [DF_ASSET_STATUS] DEFAULT ('') NOT NULL,
    [FISICAL_STATUS]                     NVARCHAR (25)   NULL,
    [INSURANCE_STATUS]                   NVARCHAR (10)   NULL,
    [CLAIM_STATUS]                       NVARCHAR (10)   NULL,
    [RENTAL_STATUS]                      NVARCHAR (25)   NULL,
    [RENTAL_REFF_NO]                     NVARCHAR (50)   NULL,
    [RESERVED_BY]                        NVARCHAR (50)   NULL,
    [RESERVED_DATE]                      DATETIME        NULL,
    [PO_NO]                              NVARCHAR (50)   CONSTRAINT [DF_ASSET_PO_NO] DEFAULT ('') NULL,
    [REQUESTOR_CODE]                     NVARCHAR (50)   CONSTRAINT [DF_ASSET_REQUESTOR_CODE] DEFAULT ('') NULL,
    [REQUESTOR_NAME]                     NVARCHAR (250)  CONSTRAINT [DF_ASSET_REQUESTOR_NAME] DEFAULT ('') NULL,
    [VENDOR_CODE]                        NVARCHAR (50)   CONSTRAINT [DF_ASSET_VENDOR_CODE] DEFAULT ('') NOT NULL,
    [VENDOR_NAME]                        NVARCHAR (250)  CONSTRAINT [DF_ASSET_VENDOR_NAME] DEFAULT ('') NOT NULL,
    [TYPE_CODE]                          NVARCHAR (50)   CONSTRAINT [DF_ASSET_TYPE_CODE] DEFAULT ('') NULL,
    [CATEGORY_CODE]                      NVARCHAR (50)   CONSTRAINT [DF_ASSET_CATEGORY_CODE] DEFAULT ('') NULL,
    [CATEGORY_NAME]                      NVARCHAR (250)  CONSTRAINT [DF_ASSET_VENDOR_NAME1] DEFAULT ('') NULL,
    [PO_DATE]                            DATETIME        NULL,
    [PURCHASE_DATE]                      DATETIME        NOT NULL,
    [PURCHASE_PRICE]                     DECIMAL (18, 2) CONSTRAINT [DF_ASSET_PURCHASE_PRICE] DEFAULT ((0)) NOT NULL,
    [INVOICE_NO]                         NVARCHAR (50)   CONSTRAINT [DF_ASSET_INVOICE_NO] DEFAULT ('') NULL,
    [INVOICE_DATE]                       DATETIME        CONSTRAINT [DF_ASSET_INVOICE_DATE] DEFAULT ('') NULL,
    [ORIGINAL_PRICE]                     DECIMAL (18, 2) CONSTRAINT [DF_ASSET_ORIGINAL_PRICE] DEFAULT ((0)) NOT NULL,
    [SALE_AMOUNT]                        DECIMAL (18, 2) CONSTRAINT [DF_ASSET_SALE_AMOUNT] DEFAULT ((0)) NULL,
    [SALE_DATE]                          DATETIME        NULL,
    [DISPOSAL_DATE]                      DATETIME        NULL,
    [BRANCH_CODE]                        NVARCHAR (50)   CONSTRAINT [DF_ASSET_BRANCH_CODE] DEFAULT ('') NOT NULL,
    [BRANCH_NAME]                        NVARCHAR (250)  CONSTRAINT [DF_ASSET_BRANCH_NAME] DEFAULT ('') NOT NULL,
    [DIVISION_CODE]                      NVARCHAR (50)   CONSTRAINT [DF_ASSET_DIVISION_CODE] DEFAULT ('') NULL,
    [DIVISION_NAME]                      NVARCHAR (250)  CONSTRAINT [DF_ASSET_DIVISION_NAME] DEFAULT ('') NULL,
    [DEPARTMENT_CODE]                    NVARCHAR (50)   CONSTRAINT [DF_ASSET_DEPARTMENT_CODE] DEFAULT ('') NULL,
    [DEPARTMENT_NAME]                    NVARCHAR (250)  CONSTRAINT [DF_ASSET_DEPARTMENT_NAME] DEFAULT ('') NULL,
    [PIC_CODE]                           NVARCHAR (50)   CONSTRAINT [DF_ASSET_PIC_CODE] DEFAULT ('') NULL,
    [PIC_NAME]                           NVARCHAR (250)  CONSTRAINT [DF_ASSET_LOCATION_NAME1] DEFAULT ('') NULL,
    [RESIDUAL_VALUE]                     DECIMAL (18, 2) CONSTRAINT [DF_ASSET_RESIDUAL_VALUE] DEFAULT ((0)) NULL,
    [IS_DEPRE]                           NVARCHAR (1)    CONSTRAINT [DF_ASSET_IS_RENTAL1] DEFAULT ((0)) NULL,
    [DEPRE_CATEGORY_COMM_CODE]           NVARCHAR (50)   CONSTRAINT [DF_ASSET_DEPRE_CATEGORY_COMM_CODE] DEFAULT ('') NOT NULL,
    [TOTAL_DEPRE_COMM]                   DECIMAL (18, 2) CONSTRAINT [DF_ASSET_TOTAL_DEPRE_COMM] DEFAULT ((0)) NOT NULL,
    [DEPRE_PERIOD_COMM]                  NVARCHAR (6)    CONSTRAINT [DF_ASSET_DEPRE_PERIOD_COMM] DEFAULT ((0)) NULL,
    [NET_BOOK_VALUE_COMM]                DECIMAL (18, 2) CONSTRAINT [DF_ASSET_NET_BOOK_VALUE_COMM] DEFAULT ((0)) NOT NULL,
    [DEPRE_CATEGORY_FISCAL_CODE]         NVARCHAR (50)   CONSTRAINT [DF_ASSET_DEPRE_CATEGORY_FISCAL_CODE] DEFAULT ('') NOT NULL,
    [TOTAL_DEPRE_FISCAL]                 DECIMAL (18, 2) CONSTRAINT [DF_ASSET_TOTAL_DEPRE_FISCAL] DEFAULT ((0)) NOT NULL,
    [DEPRE_PERIOD_FISCAL]                NVARCHAR (6)    CONSTRAINT [DF_ASSET_DEPRE_PERIOD_FISCAL] DEFAULT ('') NULL,
    [NET_BOOK_VALUE_FISCAL]              DECIMAL (18, 2) CONSTRAINT [DF_ASSET_NET_BOOK_VALUE_FISCAL] DEFAULT ((0)) NOT NULL,
    [IS_RENTAL]                          NVARCHAR (1)    CONSTRAINT [DF_ASSET_IS_RENTAL] DEFAULT ((0)) NULL,
    [CONTRACTOR_NAME]                    NVARCHAR (250)  CONSTRAINT [DF_FA_ASSET_CONTRACTOR_NAME_1] DEFAULT ('') NULL,
    [CONTRACTOR_ADDRESS]                 NVARCHAR (4000) CONSTRAINT [DF_FA_ASSET_CONTRACTOR_ADDRESS_1] DEFAULT ('') NULL,
    [CONTRACTOR_EMAIL]                   NVARCHAR (50)   CONSTRAINT [DF_FA_ASSET_CONTRACTOR_EMAIL_1] DEFAULT ('') NULL,
    [CONTRACTOR_PIC]                     NVARCHAR (250)  CONSTRAINT [DF_FA_ASSET_CONTRACTOR_PIC_1] DEFAULT ('') NULL,
    [CONTRACTOR_PIC_PHONE]               NVARCHAR (25)   CONSTRAINT [DF_FA_ASSET_CONTRACTOR_PIC_PHONE_1] DEFAULT ('') NULL,
    [CONTRACTOR_START_DATE]              DATETIME        CONSTRAINT [DF_FA_ASSET_CONTRACTOR_START_DATE_1] DEFAULT ('') NULL,
    [CONTRACTOR_END_DATE]                DATETIME        CONSTRAINT [DF_FA_ASSET_CONTRACTOR_END_DATE_1] DEFAULT ('') NULL,
    [WARRANTY]                           INT             NULL,
    [WARRANTY_START_DATE]                DATETIME        NULL,
    [WARRANTY_END_DATE]                  DATETIME        NULL,
    [REMARKS_WARRANTY]                   NVARCHAR (4000) CONSTRAINT [DF_ASSET_REMARKS_WARRANTY] DEFAULT ('') NULL,
    [IS_MAINTENANCE]                     NVARCHAR (1)    CONSTRAINT [DF_ASSET_IS_MAINTENANCE] DEFAULT ('') NULL,
    [MAINTENANCE_TIME]                   INT             CONSTRAINT [DF_ASSET_MAINTENANCE_TIME] DEFAULT ((0)) NULL,
    [MAINTENANCE_TYPE]                   NVARCHAR (50)   CONSTRAINT [DF_ASSET_MAINTENANCE_TYPE] DEFAULT ('') NULL,
    [MAINTENANCE_CYCLE_TIME]             INT             CONSTRAINT [DF_ASSET_MAINTENANCE_CYCLE_TIME] DEFAULT ((0)) NULL,
    [MAINTENANCE_START_DATE]             DATETIME        NULL,
    [USE_LIFE]                           NVARCHAR (15)   NULL,
    [LAST_METER]                         NVARCHAR (15)   NULL,
    [LAST_SERVICE_DATE]                  DATETIME        NULL,
    [PPH]                                DECIMAL (18, 6) CONSTRAINT [DF_ASSET_PPH] DEFAULT ((0)) NULL,
    [PPN]                                DECIMAL (18, 6) CONSTRAINT [DF_ASSET_PPH1] DEFAULT ((0)) NULL,
    [REMARKS]                            NVARCHAR (4000) CONSTRAINT [DF_ASSET_REMARKS] DEFAULT ('') NULL,
    [LAST_SO_DATE]                       DATETIME        NULL,
    [LAST_SO_CONDITION]                  NVARCHAR (50)   NULL,
    [LAST_USED_BY_CODE]                  NVARCHAR (50)   NULL,
    [LAST_USED_BY_NAME]                  NVARCHAR (250)  CONSTRAINT [DF_ASSET_LOCATION_NAME1_1] DEFAULT ('') NULL,
    [LAST_LOCATION_CODE]                 NVARCHAR (50)   NULL,
    [LAST_LOCATION_NAME]                 NVARCHAR (250)  CONSTRAINT [DF_ASSET_LAST_USED_BY_NAME1] DEFAULT ('') NULL,
    [IS_PO]                              NVARCHAR (1)    CONSTRAINT [DF_ASSET_LAST_LOCATION_NAME1] DEFAULT ('') NULL,
    [IS_LOCK]                            NVARCHAR (1)    NULL,
    [IS_PERMIT_TO_SELL]                  NVARCHAR (1)    NULL,
    [PERMIT_SELL_REMARK]                 NVARCHAR (4000) NULL,
    [SELL_REQUEST_AMOUNT]                DECIMAL (18, 2) NULL,
    [ASSET_PURPOSE]                      NVARCHAR (50)   NULL,
    [ASSET_FROM]                         NVARCHAR (50)   NULL,
    [MODEL_CODE]                         NVARCHAR (50)   NULL,
    [MODEL_NAME]                         NVARCHAR (250)  NULL,
    [MERK_CODE]                          NVARCHAR (50)   NULL,
    [MERK_NAME]                          NVARCHAR (250)  NULL,
    [TYPE_CODE_ASSET]                    NVARCHAR (50)   NULL,
    [TYPE_NAME_ASSET]                    NVARCHAR (250)  NULL,
    [UNIT_PROVINCE_CODE]                 NVARCHAR (50)   NULL,
    [UNIT_PROVINCE_NAME]                 NVARCHAR (250)  NULL,
    [UNIT_CITY_CODE]                     NVARCHAR (50)   NULL,
    [UNIT_CITY_NAME]                     NVARCHAR (250)  NULL,
    [PARKING_LOCATION]                   NVARCHAR (250)  NULL,
    [PROCESS_STATUS]                     NVARCHAR (50)   NULL,
    [AGREEMENT_NO]                       NVARCHAR (50)   NULL,
    [AGREEMENT_EXTERNAL_NO]              NVARCHAR (50)   NULL,
    [ASSET_NO]                           NVARCHAR (50)   NULL,
    [CLIENT_NO]                          NVARCHAR (50)   NULL,
    [CLIENT_NAME]                        NVARCHAR (250)  NULL,
    [SPAF_PCT]                           DECIMAL (9, 6)  NULL,
    [START_PERIOD_DATE]                  DATETIME        NULL,
    [END_PERIOD_DATE]                    DATETIME        NULL,
    [SPAF_AMOUNT]                        DECIMAL (18, 2) NULL,
    [SUBVENTION_AMOUNT]                  DECIMAL (18, 2) NULL,
    [IS_SPAF_USE]                        NVARCHAR (1)    CONSTRAINT [DF_ASSET_IS_SPAF_USE] DEFAULT ((0)) NOT NULL,
    [CLAIM_SPAF]                         NVARCHAR (50)   NULL,
    [CLAIM_SPAF_DATE]                    DATETIME        NULL,
    [ACTIVITY_STATUS]                    NVARCHAR (250)  CONSTRAINT [DF_ASSET_CHANGE_TYPE] DEFAULT ('') NOT NULL,
    [WO_NO]                              NVARCHAR (50)   NULL,
    [CRE_DATE]                           DATETIME        NOT NULL,
    [CRE_BY]                             NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                     NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                           DATETIME        NOT NULL,
    [MOD_BY]                             NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                     NVARCHAR (15)   NOT NULL,
    [WO_STATUS]                          NVARCHAR (50)   NULL,
    [PERMIT_SELL_DATE]                   DATETIME        NULL,
    [DISCOUNT_AMOUNT]                    DECIMAL (18, 2) NULL,
    [PPN_AMOUNT]                         DECIMAL (18, 2) NULL,
    [PPH_AMOUNT]                         DECIMAL (18, 2) NULL,
    [RE_RENT_STATUS]                     NVARCHAR (10)   NULL,
    [POSTING_DATE]                       DATETIME        NULL,
    [LAST_KM_SERVICE]                    INT             NULL,
    [OLD_PURCHASE_PRICE]                 DECIMAL (18, 2) NULL,
    [OLD_ORIGINAL_PRICE]                 DECIMAL (18, 2) NULL,
    [OLD_NET_BOOK_VALUE_COMMERCIAL]      DECIMAL (18, 2) NULL,
    [OLD_NET_BOOK_VALUE_FISCAL]          DECIMAL (18, 2) NULL,
    [INVOICE_POST_DATE]                  DATETIME        NULL,
    [INVOICE_RETURN_DATE]                DATETIME        NULL,
    [IS_FINAL_GRN]                       NVARCHAR (1)    NULL,
    [IS_INVOICE_ASSET_PAID]              NVARCHAR (1)    NULL,
    [IS_INVOICE_KAROSERI_AKSESORIS_PAID] NVARCHAR (1)    NULL,
    [FINAL_DATE]                         DATETIME        NULL,
    [IS_GPS]                             NVARCHAR (1)    NULL,
    [GPS_STATUS]                         NVARCHAR (50)   NULL,
    [REMARK_UPDATE_LOCATION]             NVARCHAR (4000) NULL,
    [UPDATE_LOCATION_DATE]               DATETIME        NULL,
    [STATUS_CONDITION]                   NVARCHAR (250)  NULL,
    [STATUS_PROGRESS]                    NVARCHAR (250)  NULL,
    [STATUS_REMARK]                      NVARCHAR (4000) NULL,
    [STATUS_LAST_UPDATE_BY]              NVARCHAR (50)   NULL,
    [STATUS_LAST_UPDATE_DATE]            DATETIME        NULL,
    [MONITORING_STATUS]                  NVARCHAR (25)   NULL,
    [is_update_location]                 NVARCHAR (1)    NULL,
    [GPS_VENDOR_CODE]                    NVARCHAR (50)   NULL,
    [GPS_VENDOR_NAME]                    NVARCHAR (250)  NULL,
    [GPS_RECEIVED_DATE]                  DATETIME        NULL,
    CONSTRAINT [PK_ASSET_1] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_ASSET_STATUS_PURCHASE_DATE]
    ON [dbo].[ASSET]([STATUS] ASC, [PURCHASE_DATE] ASC)
    INCLUDE([ITEM_CODE], [ITEM_NAME], [BARCODE], [CATEGORY_CODE], [PURCHASE_PRICE], [BRANCH_CODE], [BRANCH_NAME], [RESIDUAL_VALUE], [TOTAL_DEPRE_COMM], [NET_BOOK_VALUE_COMM], [TOTAL_DEPRE_FISCAL], [NET_BOOK_VALUE_FISCAL], [USE_LIFE]);


GO
CREATE NONCLUSTERED INDEX [IDX_ASSET_STATUS_BRANCH_CODE_PURCHASE_DATE]
    ON [dbo].[ASSET]([STATUS] ASC, [BRANCH_CODE] ASC, [PURCHASE_DATE] ASC)
    INCLUDE([ITEM_CODE], [ITEM_NAME], [BARCODE], [CATEGORY_CODE], [PURCHASE_PRICE], [BRANCH_NAME], [RESIDUAL_VALUE], [TOTAL_DEPRE_COMM], [NET_BOOK_VALUE_COMM], [TOTAL_DEPRE_FISCAL], [NET_BOOK_VALUE_FISCAL], [USE_LIFE]);


GO
CREATE NONCLUSTERED INDEX [IDX_ASSET_ITEM_CODE_STATUS_PURCHASE_DATE]
    ON [dbo].[ASSET]([ITEM_CODE] ASC, [STATUS] ASC, [PURCHASE_DATE] ASC)
    INCLUDE([ITEM_NAME], [BARCODE], [CATEGORY_CODE], [PURCHASE_PRICE], [BRANCH_CODE], [BRANCH_NAME], [RESIDUAL_VALUE], [TOTAL_DEPRE_COMM], [NET_BOOK_VALUE_COMM], [TOTAL_DEPRE_FISCAL], [NET_BOOK_VALUE_FISCAL], [USE_LIFE]);


GO
CREATE NONCLUSTERED INDEX [IDX_ASSET_20230829]
    ON [dbo].[ASSET]([COMPANY_CODE] ASC, [BRANCH_CODE] ASC, [STATUS] ASC)
    INCLUDE([ITEM_NAME], [BARCODE], [BRANCH_NAME], [DIVISION_CODE], [DIVISION_NAME], [DEPARTMENT_CODE], [DEPARTMENT_NAME]);


GO
CREATE NONCLUSTERED INDEX [IDX_ASSET_20231009]
    ON [dbo].[ASSET]([IS_MAINTENANCE] ASC, [STATUS] ASC)
    INCLUDE([ITEM_NAME], [RENTAL_STATUS], [BRANCH_CODE], [BRANCH_NAME], [LAST_METER]);


GO
CREATE NONCLUSTERED INDEX [IDX_ASSET_STATUS]
    ON [dbo].[ASSET]([STATUS] ASC)
    INCLUDE([BARCODE], [PURCHASE_PRICE], [IS_PERMIT_TO_SELL]);


GO
CREATE NONCLUSTERED INDEX [IDX_ASSET_AGREEMENT_NO]
    ON [dbo].[ASSET]([AGREEMENT_NO] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CODE ASSET', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DSF', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'COMPANY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CODE ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'ITEM_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'ITEM_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CODE ITEM GROUP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'ITEM_GROUP_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KONDISI ASSET', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'CONDITION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'STATUS ASSET', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'STATUS FISIK ASSET', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'FISICAL_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SATUS ASURANSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'INSURANCE_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'STATUS PENGAJUAN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'CLAIM_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'STATUS PENYEWAAN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'RENTAL_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NO ALLOCATION', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'RENTAL_REFF_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA PENYEWA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'RESERVED_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOMER PURCHASE ORDER', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'PO_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CODE REQUESTOR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'REQUESTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA REQUESTOR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'REQUESTOR_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CODE VENDOR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'VENDOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA VENDOR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'VENDOR_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TYPE_CODE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CODE CATEGORY ASSET', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA CATEGORY ASSET', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'CATEGORY_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TANGGAL PURCHASE ORDER', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'PO_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TANGGAL PEMBELIAN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'PURCHASE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'HARGA PEMBELIAN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'PURCHASE_PRICE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOMER INVOICE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'INVOICE_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TANGGAL INVOICE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'INVOICE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'HARGA ASLI ASSET', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'ORIGINAL_PRICE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'HARGA JUAL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'SALE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TANGGAL JUAL ASSET', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'SALE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TANGGAL DISPOSE ASSET', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'DISPOSAL_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CODE CABANG', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA CABANG', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CODE DIVISI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'DIVISION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA DIVISI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'DIVISION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CODE DEPARTMENT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'DEPARTMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA DEPARTMENT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'DEPARTMENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NILAI SISA ASSET', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'RESIDUAL_VALUE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DEPRE ATAU TIDAK', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'IS_DEPRE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CODE DEPRE COMMERCIAL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'DEPRE_CATEGORY_COMM_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TOTAL DEPRESIASI COMMERCIAL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'TOTAL_DEPRE_COMM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PERIODE DEPRE COMMERCIAL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'DEPRE_PERIOD_COMM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe pembayaran pertama pada kontrak pembiayaan tersebut - ADVANCE, menginformasikan bahwa angsuran pertama dibayarkan didepan - ARREAR, menginformasikan bahwa angsuran pertama dibayarkan dibelakang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'USE_LIFE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe pembayaran pertama pada kontrak pembiayaan tersebut - ADVANCE, menginformasikan bahwa angsuran pertama dibayarkan didepan - ARREAR, menginformasikan bahwa angsuran pertama dibayarkan dibelakang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'LAST_METER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe pembayaran pertama pada kontrak pembiayaan tersebut - ADVANCE, menginformasikan bahwa angsuran pertama dibayarkan didepan - ARREAR, menginformasikan bahwa angsuran pertama dibayarkan dibelakang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'LAST_USED_BY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe pembayaran pertama pada kontrak pembiayaan tersebut - ADVANCE, menginformasikan bahwa angsuran pertama dibayarkan didepan - ARREAR, menginformasikan bahwa angsuran pertama dibayarkan dibelakang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET', @level2type = N'COLUMN', @level2name = N'LAST_LOCATION_CODE';

