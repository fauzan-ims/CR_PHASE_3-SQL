CREATE TABLE [dbo].[APPLICATION_ASSET] (
    [ASSET_NO]                            NVARCHAR (50)   NOT NULL,
    [APPLICATION_NO]                      NVARCHAR (50)   NOT NULL,
    [ASSET_TYPE_CODE]                     NVARCHAR (50)   NOT NULL,
    [ASSET_NAME]                          NVARCHAR (250)  NOT NULL,
    [ASSET_YEAR]                          NVARCHAR (4)    NOT NULL,
    [ASSET_CONDITION]                     NVARCHAR (5)    NOT NULL,
    [UNIT_CODE]                           NVARCHAR (50)   CONSTRAINT [DF_APPLICATION_ASSET_UNIT_CODE] DEFAULT ('') NOT NULL,
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
    [IS_PURCHASE_REQUIREMENT_AFTER_LEASE] NVARCHAR (1)    NULL,
    [DELIVER_TO]                          NVARCHAR (10)   NOT NULL,
    [DELIVER_TO_NAME]                     NVARCHAR (250)  NOT NULL,
    [DELIVER_TO_AREA_NO]                  NVARCHAR (4)    NOT NULL,
    [DELIVER_TO_PHONE_NO]                 NVARCHAR (15)   NOT NULL,
    [DELIVER_TO_ADDRESS]                  NVARCHAR (4000) NOT NULL,
    [PICKUP_NAME]                         NVARCHAR (250)  NULL,
    [PICKUP_PHONE_AREA_NO]                NVARCHAR (4)    NULL,
    [PICKUP_PHONE_NO]                     NVARCHAR (15)   NULL,
    [PICKUP_ADDRESS]                      NVARCHAR (4000) NULL,
    [MARKET_VALUE]                        DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_MARKET_VALUE] DEFAULT ((0)) NOT NULL,
    [KAROSERI_AMOUNT]                     DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_KAROSERI_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ACCESSORIES_AMOUNT]                  DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_ACCESSORIES_AMOUNT] DEFAULT ((0)) NOT NULL,
    [MOBILIZATION_AMOUNT]                 DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_MOBILIZATION_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ASSET_AMOUNT]                        DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_LOAN_VALUE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [ASSET_INTEREST_RATE]                 DECIMAL (9, 6)  CONSTRAINT [DF_APPLICATION_ASSET_ASSET_AMOUNT1] DEFAULT ((0)) NULL,
    [ASSET_INTEREST_AMOUNT]               DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_ASSET_INTEREST_RATE1] DEFAULT ((0)) NOT NULL,
    [ASSET_RV_PCT]                        DECIMAL (9, 6)  NULL,
    [ASSET_RV_AMOUNT]                     DECIMAL (18, 2) NOT NULL,
    [PERIODE]                             INT             NOT NULL,
    [LEASE_OPTION]                        NVARCHAR (10)   NOT NULL,
    [COGS_AMOUNT]                         DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_COGS_AMOUNT] DEFAULT ((0)) NOT NULL,
    [BASIC_LEASE_AMOUNT]                  DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_BASIC_LEASE] DEFAULT ((0)) NOT NULL,
    [MARGIN_BY]                           NVARCHAR (10)   NOT NULL,
    [MARGIN_RATE]                         DECIMAL (9, 6)  CONSTRAINT [DF_APPLICATION_ASSET_MARGIN_RATE] DEFAULT ((0)) NULL,
    [MARGIN_AMOUNT]                       DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_BASIC_LEASE_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [ADDITIONAL_CHARGE_RATE]              DECIMAL (9, 6)  CONSTRAINT [DF_APPLICATION_ASSET_MARGIN_RATE1] DEFAULT ((0)) NULL,
    [ADDITIONAL_CHARGE_AMOUNT]            DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_MARGIN_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [LEASE_AMOUNT]                        DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_ADDITIONAL_CHARGE_AMOUNT2] DEFAULT ((0)) NOT NULL,
    [ROUND_TYPE]                          NVARCHAR (10)   NOT NULL,
    [ROUND_AMOUNT]                        DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_ADDITIONAL_CHARGE_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [LEASE_ROUNDED_AMOUNT]                DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_ROUND_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [NET_MARGIN_AMOUNT]                   DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_ADDITIONAL_CHARGE_AMOUNT1_1] DEFAULT ((0)) NOT NULL,
    [HANDOVER_CODE]                       NVARCHAR (50)   NULL,
    [HANDOVER_BAST_DATE]                  DATETIME        NULL,
    [HANDOVER_STATUS]                     NVARCHAR (10)   NULL,
    [HANDOVER_REMARK]                     NVARCHAR (4000) NULL,
    [PURCHASE_CODE]                       NVARCHAR (50)   NULL,
    [PURCHASE_STATUS]                     NVARCHAR (15)   NULL,
    [PURCHASE_GTS_CODE]                   NVARCHAR (50)   NULL,
    [PURCHASE_GTS_STATUS]                 NVARCHAR (15)   NULL,
    [FA_CODE]                             NVARCHAR (50)   NULL,
    [FA_NAME]                             NVARCHAR (250)  NULL,
    [FA_REFF_NO_01]                       NVARCHAR (250)  NULL,
    [FA_REFF_NO_02]                       NVARCHAR (250)  NULL,
    [FA_REFF_NO_03]                       NVARCHAR (250)  NULL,
    [REPLACEMENT_FA_CODE]                 NVARCHAR (50)   NULL,
    [REPLACEMENT_FA_NAME]                 NVARCHAR (250)  NULL,
    [REPLACEMENT_FA_REFF_NO_01]           NVARCHAR (250)  NULL,
    [REPLACEMENT_FA_REFF_NO_02]           NVARCHAR (250)  NULL,
    [REPLACEMENT_FA_REFF_NO_03]           NVARCHAR (250)  NULL,
    [REALIZATION_CODE]                    NVARCHAR (50)   NULL,
    [REQUEST_DELIVERY_DATE]               DATETIME        NULL,
    [BAST_DATE]                           DATETIME        NULL,
    [FIRST_RENTAL_DATE]                   DATETIME        NULL,
    [BUDGET_APPROVAL_CODE]                NVARCHAR (50)   NULL,
    [IS_ASSET_DELIVERY_REQUEST_PRINTED]   NVARCHAR (1)    CONSTRAINT [DF_APPLICATION_ASSET_IS_ASSET_DELIVERY_REQUEST_PRINTED] DEFAULT ('0') NULL,
    [IS_CALCULATE_AMORTIZE]               NVARCHAR (1)    CONSTRAINT [DF_APPLICATION_ASSET_IS_CALCULATE_AMORTIZE] DEFAULT ('0') NULL,
    [IS_REQUEST_GTS]                      NVARCHAR (1)    CONSTRAINT [DF_APPLICATION_ASSET_IS_REQUEST_GTS] DEFAULT ((0)) NULL,
    [ESTIMATE_PO_DATE]                    DATETIME        NULL,
    [EMAIL]                               NVARCHAR (250)  NULL,
    [IS_AUTO_EMAIL]                       NVARCHAR (1)    CONSTRAINT [DF_APPLICATION_ASSET_IS_AUTO_EMAIL] DEFAULT ((1)) NULL,
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
    [IS_USE_INSURANCE]                    NVARCHAR (1)    NULL,
    [IS_BBN_CLIENT]                       NVARCHAR (1)    NULL,
    [CLIENT_BBN_NAME]                     NVARCHAR (250)  NULL,
    [CLIENT_BBN_ADDRESS]                  NVARCHAR (4000) NULL,
    [PMT_AMOUNT]                          DECIMAL (18, 2) NULL,
    [INITIAL_PRICE_AMOUNT]                DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_INITIAL_PRICE_AMOUNT] DEFAULT ((0)) NULL,
    [SUBVENTION_AMOUNT]                   DECIMAL (18, 2) NULL,
    [SPAF_AMOUNT]                         DECIMAL (18, 2) NULL,
    [INSURANCE_COMMISSION_AMOUNT]         DECIMAL (18, 2) NULL,
    [AVERAGE_ASSET_AMOUNT]                DECIMAL (18, 2) NULL,
    [YEARLY_PROFIT_AMOUNT]                DECIMAL (18, 2) NULL,
    [ROA_PCT]                             DECIMAL (9, 6)  NULL,
    [MOBILIZATION_CITY_CODE]              NVARCHAR (50)   NULL,
    [MOBILIZATION_CITY_DESCRIPTION]       NVARCHAR (250)  NULL,
    [MOBILIZATION_PROVINCE_CODE]          NVARCHAR (50)   NULL,
    [MOBILIZATION_PROVINCE_DESCRIPTION]   NVARCHAR (250)  NULL,
    [BORROWING_INTEREST_RATE]             DECIMAL (9, 6)  CONSTRAINT [DF_APPLICATION_ASSET_ASSET_INTEREST_RATE1_1] DEFAULT ((0)) NULL,
    [BORROWING_INTEREST_AMOUNT]           DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_ASSET_INTEREST_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [DISCOUNT_AMOUNT]                     DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_BORROWING_INTEREST_AMOUNT3] DEFAULT ((0)) NOT NULL,
    [DISCOUNT_KAROSERI_AMOUNT]            DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_BORROWING_INTEREST_AMOUNT2] DEFAULT ((0)) NOT NULL,
    [DISCOUNT_ACCESSORIES_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_BORROWING_INTEREST_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [SURAT_NO]                            NVARCHAR (50)   NULL,
    [AGREEMENT_NO]                        NVARCHAR (50)   NULL,
    [CRE_DATE]                            DATETIME        NOT NULL,
    [CRE_BY]                              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                            DATETIME        NOT NULL,
    [MOD_BY]                              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                      NVARCHAR (15)   NOT NULL,
    [OTR_AMOUNT]                          DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_ASSET_OTR_AMOUNT] DEFAULT ((0)) NOT NULL,
    [IS_CANCEL]                           NVARCHAR (1)    DEFAULT ((0)) NULL,
    [MONTHLY_RENTAL_ROUNDED_AMOUNT]       DECIMAL (18, 2) NULL,
    [IS_USE_GPS]                          NVARCHAR (1)    NULL,
    [GPS_MONTHLY_AMOUNT]                  DECIMAL (18, 2) NULL,
    [GPS_INSTALLATION_AMOUNT]             DECIMAL (18, 2) NULL,
    [CLIENT_NITKU]                        NVARCHAR (50)   NULL,
    [ASSET_STATUS]                        NVARCHAR (20)   NULL,
    [UNIT_SOURCE]                         NVARCHAR (20)   NULL,
    [START_DUE_DATE]                      DATETIME        NULL,
    [PRORATE]                             NVARCHAR (10)   NULL,
    CONSTRAINT [PK_APPLICATION_ASSET] PRIMARY KEY CLUSTERED ([ASSET_NO] ASC),
    CONSTRAINT [FK_APPLICATION_ASSET_APPLICATION_MAIN] FOREIGN KEY ([APPLICATION_NO]) REFERENCES [dbo].[APPLICATION_MAIN] ([APPLICATION_NO]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_APPLICATION_ASSET_PURCHASE_REQUEST] FOREIGN KEY ([PURCHASE_CODE]) REFERENCES [dbo].[PURCHASE_REQUEST] ([CODE])
);


GO
CREATE NONCLUSTERED INDEX [IDX_APPLICATION_ASSET_20230908]
    ON [dbo].[APPLICATION_ASSET]([APPLICATION_NO] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'APPLICATION_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'VHCL, MCHN, ...', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama asset', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tahun pembuatan dari asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_YEAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kondisi asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_CONDITION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CLIENT, OTHER', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'BILLING_TO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'BY DATE, BEFORE_DUE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'BILLING_MODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CLIENT, OTHER', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'DELIVER_TO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Harga asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'MARKET_VALUE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Harga asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'KAROSERI_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Harga asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'ACCESSORIES_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Harga asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'MOBILIZATION_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai asset', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest rate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_INTEREST_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_INTEREST_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FULL, NON MAINTENENCE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'LEASE_OPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ALL, VARIABLE  ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'MARGIN_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rental , before rounding', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'LEASE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rounding type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'ROUND_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rounding amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'ROUND_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rental after rounding', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'LEASE_ROUNDED_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'informasi reference number ( plat no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'FA_REFF_NO_01';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'informasi reference number ( chasis no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'FA_REFF_NO_02';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'informasi reference number ( engine no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'FA_REFF_NO_03';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest rate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'BORROWING_INTEREST_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'BORROWING_INTEREST_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'DISCOUNT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'DISCOUNT_KAROSERI_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'interest amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_ASSET', @level2type = N'COLUMN', @level2name = N'DISCOUNT_ACCESSORIES_AMOUNT';

