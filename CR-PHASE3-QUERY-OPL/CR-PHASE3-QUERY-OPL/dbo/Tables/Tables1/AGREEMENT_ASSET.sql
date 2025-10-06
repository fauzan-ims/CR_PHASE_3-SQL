CREATE TABLE [dbo].[AGREEMENT_ASSET] (
    [ASSET_NO]                            NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]                        NVARCHAR (50)   NOT NULL,
    [ASSET_TYPE_CODE]                     NVARCHAR (50)   NOT NULL,
    [ASSET_NAME]                          NVARCHAR (250)  NOT NULL,
    [ASSET_YEAR]                          NVARCHAR (4)    NOT NULL,
    [ASSET_CONDITION]                     NVARCHAR (5)    NOT NULL,
    [ASSET_STATUS]                        NVARCHAR (20)   CONSTRAINT [DF_AGREEMENT_ASSET_ASSET_STATUS] DEFAULT (N'ON CUSTOMER') NOT NULL,
    [BILLING_TO]                          NVARCHAR (10)   NOT NULL,
    [BILLING_TO_NAME]                     NVARCHAR (250)  NOT NULL,
    [BILLING_TO_AREA_NO]                  NVARCHAR (4)    NOT NULL,
    [BILLING_TO_PHONE_NO]                 NVARCHAR (15)   NOT NULL,
    [BILLING_TO_ADDRESS]                  NVARCHAR (4000) NOT NULL,
    [BILLING_TO_FAKTUR_TYPE]              NVARCHAR (3)    NULL,
    [BILLING_TYPE]                        NVARCHAR (50)   NOT NULL,
    [BILLING_MODE]                        NVARCHAR (10)   NOT NULL,
    [BILLING_MODE_DATE]                   INT             NOT NULL,
    [BILLING_TO_NPWP]                     NVARCHAR (20)   NULL,
    [NPWP_NAME]                           NVARCHAR (250)  NULL,
    [NPWP_ADDRESS]                        NVARCHAR (4000) NULL,
    [IS_PURCHASE_REQUIREMENT_AFTER_LEASE] NVARCHAR (1)    NOT NULL,
    [DELIVER_TO]                          NVARCHAR (10)   NOT NULL,
    [DELIVER_TO_NAME]                     NVARCHAR (250)  NOT NULL,
    [DELIVER_TO_AREA_NO]                  NVARCHAR (4)    NOT NULL,
    [DELIVER_TO_PHONE_NO]                 NVARCHAR (15)   NOT NULL,
    [DELIVER_TO_ADDRESS]                  NVARCHAR (4000) NOT NULL,
    [PICKUP_NAME]                         NVARCHAR (250)  NULL,
    [PICKUP_PHONE_AREA_NO]                NVARCHAR (4)    NULL,
    [PICKUP_PHONE_NO]                     NVARCHAR (15)   NULL,
    [PICKUP_ADDRESS]                      NVARCHAR (4000) NULL,
    [MARKET_VALUE]                        DECIMAL (18, 2) NOT NULL,
    [KAROSERI_AMOUNT]                     DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_KAROSERI_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ACCESSORIES_AMOUNT]                  DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_ACCESSORIES_AMOUNT] DEFAULT ((0)) NOT NULL,
    [MOBILIZATION_AMOUNT]                 DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_ACCESSORIES_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [ASSET_AMOUNT]                        DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_LOAN_VALUE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ASSET_INTEREST_RATE]                 DECIMAL (9, 6)  CONSTRAINT [DF_AGREEMENT_ASSET_ASSET_INTEREST_RATE] DEFAULT ((0)) NULL,
    [ASSET_INTEREST_AMOUNT]               DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_ASSET_INTEREST_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ASSET_RV_PCT]                        DECIMAL (9, 6)  NULL,
    [ASSET_RV_AMOUNT]                     DECIMAL (18, 2) NOT NULL,
    [PERIODE]                             INT             NOT NULL,
    [FIRST_PAYMENT_TYPE]                  NVARCHAR (3)    NOT NULL,
    [LEASE_OPTION]                        NVARCHAR (10)   NOT NULL,
    [COGS_AMOUNT]                         DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_COGS_AMOUNT] DEFAULT ((0)) NOT NULL,
    [BASIC_LEASE_AMOUNT]                  DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_BASIC_LEASE] DEFAULT ((0)) NOT NULL,
    [MARGIN_BY]                           NVARCHAR (50)   NULL,
    [MARGIN_RATE]                         DECIMAL (9, 6)  CONSTRAINT [DF_AGREEMENT_ASSET_MARGIN_RATE] DEFAULT ((0)) NULL,
    [MARGIN_AMOUNT]                       DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_MARGIN_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ADDITIONAL_CHARGE_RATE]              DECIMAL (9, 6)  CONSTRAINT [DF_AGREEMENT_ASSET_ADDITIONAL_CHARGE_RATE] DEFAULT ((0)) NULL,
    [ADDITIONAL_CHARGE_AMOUNT]            DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_ADDITIONAL_CHARGE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [LEASE_AMOUNT]                        DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_LEASE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [LEASE_ROUND_TYPE]                    NVARCHAR (10)   NULL,
    [LEASE_ROUND_AMOUNT]                  DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_LEASE_ROUND_AMOUNT] DEFAULT ((0)) NOT NULL,
    [LEASE_ROUNDED_AMOUNT]                DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_LEASE_ROUNDED_AMOUNT] DEFAULT ((0)) NOT NULL,
    [NET_MARGIN_AMOUNT]                   DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_NET_MARGIN_AMOUNT] DEFAULT ((0)) NOT NULL,
    [HANDOVER_CODE]                       NVARCHAR (50)   NULL,
    [HANDOVER_BAST_DATE]                  DATETIME        NULL,
    [HANDOVER_STATUS]                     NVARCHAR (10)   NULL,
    [HANDOVER_REMARK]                     NVARCHAR (4000) NULL,
    [FA_CODE]                             NVARCHAR (50)   NULL,
    [FA_NAME]                             NVARCHAR (250)  NULL,
    [FA_REFF_NO_01]                       NVARCHAR (250)  NULL,
    [FA_REFF_NO_02]                       NVARCHAR (250)  NULL,
    [FA_REFF_NO_03]                       NVARCHAR (250)  NULL,
    [REPLACEMENT_FA_CODE]                 NVARCHAR (50)   NULL,
    [REPLACEMENT_FA_NAME]                 NVARCHAR (250)  CONSTRAINT [DF_AGREEMENT_ASSET_NEW_FA_NAME] DEFAULT ('') NULL,
    [REPLACEMENT_FA_REFF_NO_01]           NVARCHAR (50)   NULL,
    [REPLACEMENT_FA_REFF_NO_02]           NVARCHAR (50)   NULL,
    [REPLACEMENT_FA_REFF_NO_03]           NVARCHAR (50)   NULL,
    [REPLACEMENT_END_DATE]                DATETIME        CONSTRAINT [DF_AGREEMENT_ASSET_REPLACEMENT_FA_NAME1] DEFAULT ('') NULL,
    [RETURN_DATE]                         DATETIME        NULL,
    [RETURN_STATUS]                       NVARCHAR (10)   NULL,
    [RETURN_REMARK]                       NVARCHAR (4000) NULL,
    [EMAIL]                               NVARCHAR (250)  NULL,
    [IS_AUTO_EMAIL]                       NVARCHAR (1)    NULL,
    [IS_OTR]                              NVARCHAR (1)    NULL,
    [BBN_LOCATION_CODE]                   NVARCHAR (50)   NULL,
    [BBN_LOCATION_DESCRIPTION]            NVARCHAR (4000) NULL,
    [PLAT_COLOUR]                         NVARCHAR (10)   NULL,
    [USAGE]                               NVARCHAR (10)   NULL,
    [START_MILES]                         INT             NULL,
    [MONTHLY_MILES]                       INT             NULL,
    [IS_USE_REGISTRATION]                 NVARCHAR (1)    NULL,
    [IS_USE_REPLACEMENT]                  NVARCHAR (1)    NULL,
    [IS_USE_MAINTENANCE]                  NVARCHAR (1)    NULL,
    [ESTIMATE_DELIVERY_DATE]              DATETIME        NULL,
    [ESTIMATE_PO_DATE]                    DATETIME        NULL,
    [IS_REQUEST_GTS]                      NVARCHAR (1)    NULL,
    [IS_BBN_CLIENT]                       NVARCHAR (1)    NULL,
    [CLIENT_BBN_NAME]                     NVARCHAR (250)  NULL,
    [CLIENT_BBN_ADDRESS]                  NVARCHAR (4000) NULL,
    [PMT_AMOUNT]                          DECIMAL (18, 2) NULL,
    [INITIAL_PRICE_AMOUNT]                DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_INITIAL_PRICE_AMOUNT] DEFAULT ((0)) NULL,
    [SUBVENTION_AMOUNT]                   DECIMAL (18, 2) NULL,
    [SPAF_AMOUNT]                         DECIMAL (18, 2) NULL,
    [INSURANCE_COMMISSION_AMOUNT]         DECIMAL (18, 2) NULL,
    [AVERAGE_ASSET_AMOUNT]                DECIMAL (18, 2) NULL,
    [YEARLY_PROFIT_AMOUNT]                DECIMAL (18, 2) NULL,
    [ROA_PCT]                             DECIMAL (9, 6)  NULL,
    [BUDGET_MAINTENANCE_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_BUDGET_MAINTENENCE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [BUDGET_INSURANCE_AMOUNT]             DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_BUDGET_MAINTENENCE_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [BUDGET_REPLACEMENT_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_BUDGET_MAINTENENCE_AMOUNT1_1] DEFAULT ((0)) NOT NULL,
    [BUDGET_REGISTRATION_AMOUNT]          DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_BUDGET_MAINTENENCE_AMOUNT1_2] DEFAULT ((0)) NOT NULL,
    [TOTAL_BUDGET_AMOUNT]                 DECIMAL (18, 2) NULL,
    [MOBILIZATION_CITY_CODE]              NVARCHAR (50)   NULL,
    [MOBILIZATION_CITY_DESCRIPTION]       NVARCHAR (250)  NULL,
    [MOBILIZATION_PROVINCE_CODE]          NVARCHAR (50)   NULL,
    [MOBILIZATION_PROVINCE_DESCRIPTION]   NVARCHAR (250)  NULL,
    [BORROWING_INTEREST_RATE]             DECIMAL (9, 6)  CONSTRAINT [DF_AGREEMENT_ASSET_BORROWING_INTEREST_RATE] DEFAULT ((0)) NULL,
    [BORROWING_INTEREST_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_BORROWING_INTEREST_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DISCOUNT_AMOUNT]                     DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_DISCOUNT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DISCOUNT_KAROSERI_AMOUNT]            DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_DISCOUNT_KAROSERI_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DISCOUNT_ACCESSORIES_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_DISCOUNT_ACCESSORIES_AMOUNT] DEFAULT ((0)) NOT NULL,
    [SURAT_NO]                            NVARCHAR (50)   NULL,
    [CRE_DATE]                            DATETIME        NOT NULL,
    [CRE_BY]                              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                            DATETIME        NOT NULL,
    [MOD_BY]                              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                      NVARCHAR (15)   NOT NULL,
    [IS_INVOICE_DEDUCT_PPH]               NVARCHAR (1)    NULL,
    [IS_RECEIPT_DEDUCT_PPH]               NVARCHAR (1)    NULL,
    [OTR_AMOUNT]                          DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_ASSET_OTR_AMOUNT] DEFAULT ((0)) NOT NULL,
    [MONTHLY_RENTAL_ROUNDED_AMOUNT]       DECIMAL (18, 2) NULL,
    [IS_USE_GPS]                          NVARCHAR (1)    NULL,
    [GPS_MONTHLY_AMOUNT]                  DECIMAL (18, 2) NULL,
    [GPS_INSTALLATION_AMOUNT]             DECIMAL (18, 2) NULL,
    [CLIENT_NITKU]                        NVARCHAR (50)   NULL,
    [MATURITY_DATE]                       DATETIME        NULL,
    [UNIT_SOURCE]                         NVARCHAR (20)   NULL,
    [START_DUE_DATE]                      DATETIME        NULL,
    [PRORATE]                             NVARCHAR (10)   NULL,
    CONSTRAINT [PK_AGREEMENT_ASSET] PRIMARY KEY CLUSTERED ([ASSET_NO] ASC),
    CONSTRAINT [FK_AGREEMENT_ASSET_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IDX_AGREEMENT_ASSET_20230814]
    ON [dbo].[AGREEMENT_ASSET]([AGREEMENT_NO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_AGREEMENT_ASSET_20231009]
    ON [dbo].[AGREEMENT_ASSET]([ASSET_STATUS] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_AGREEMENT_ASSET_FA_CODE]
    ON [dbo].[AGREEMENT_ASSET]([FA_CODE] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_xsp_rpt_agreement_amortization_agreement_no]
    ON [dbo].[AGREEMENT_ASSET]([AGREEMENT_NO] ASC)
    INCLUDE([ASSET_NAME], [FA_REFF_NO_01], [REPLACEMENT_FA_REFF_NO_01]);


GO
CREATE NONCLUSTERED INDEX [IDX_20250827]
    ON [dbo].[AGREEMENT_ASSET]([AGREEMENT_NO] ASC, [ASSET_STATUS] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'VHCL, MCHN, ...', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama asset', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tahun pembuatan dari asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_YEAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kondisi asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_CONDITION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kondisi asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CLIENT, OTHER', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'BILLING_TO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MTH, BMT,ANU', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'BILLING_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'BY DATE, BEFORE_DUE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'BILLING_MODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CLIENT, OTHER', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'DELIVER_TO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Harga asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'MARKET_VALUE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Harga asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'KAROSERI_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Harga asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'ACCESSORIES_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Harga asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'MOBILIZATION_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai asset', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest rate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_INTEREST_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_INTEREST_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ADV, ARR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'FIRST_PAYMENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FULL, NON MAINTENENCE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'LEASE_OPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ALL, VARIABLE  ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'MARGIN_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'informasi reference number ( plat no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'FA_REFF_NO_01';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'informasi reference number ( chasis no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'FA_REFF_NO_02';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'informasi reference number ( engine no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'FA_REFF_NO_03';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal asset dikembalikan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'RETURN_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest rate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'BORROWING_INTEREST_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'BORROWING_INTEREST_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'DISCOUNT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'DISCOUNT_KAROSERI_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_ASSET', @level2type = N'COLUMN', @level2name = N'DISCOUNT_ACCESSORIES_AMOUNT';

