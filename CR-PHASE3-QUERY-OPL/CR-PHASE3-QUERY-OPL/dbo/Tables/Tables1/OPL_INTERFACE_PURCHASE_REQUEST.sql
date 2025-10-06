CREATE TABLE [dbo].[OPL_INTERFACE_PURCHASE_REQUEST] (
    [ID]                                BIGINT          IDENTITY (1, 1) NOT NULL,
    [CODE]                              NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]                       NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]                       NVARCHAR (250)  NOT NULL,
    [REQUEST_DATE]                      DATETIME        NOT NULL,
    [REQUEST_STATUS]                    NVARCHAR (10)   NOT NULL,
    [DESCRIPTION]                       NVARCHAR (4000) NOT NULL,
    [MARKETING_CODE]                    NVARCHAR (50)   NULL,
    [MARKETING_NAME]                    NVARCHAR (250)  NULL,
    [FA_CATEGORY_CODE]                  NVARCHAR (50)   NULL,
    [FA_CATEGORY_NAME]                  NVARCHAR (250)  NULL,
    [FA_MERK_CODE]                      NVARCHAR (50)   NULL,
    [FA_MERK_NAME]                      NVARCHAR (250)  NULL,
    [FA_MODEL_CODE]                     NVARCHAR (50)   NULL,
    [FA_MODEL_NAME]                     NVARCHAR (250)  NULL,
    [FA_TYPE_CODE]                      NVARCHAR (50)   NULL,
    [FA_TYPE_NAME]                      NVARCHAR (250)  NULL,
    [FA_UNIT_CODE]                      NVARCHAR (50)   NULL,
    [FA_UNIT_NAME]                      NVARCHAR (250)  NULL,
    [RESULT_FA_CODE]                    NVARCHAR (50)   NULL,
    [RESULT_FA_NAME]                    NVARCHAR (250)  NULL,
    [RESULT_DATE]                       DATETIME        NULL,
    [FA_REFF_NO_01]                     NVARCHAR (250)  NULL,
    [FA_REFF_NO_02]                     NVARCHAR (250)  NULL,
    [FA_REFF_NO_03]                     NVARCHAR (250)  NULL,
    [FA_REFF_NO_04]                     NVARCHAR (250)  NULL,
    [FA_REFF_NO_05]                     NVARCHAR (250)  NULL,
    [FA_REFF_NO_06]                     NVARCHAR (250)  NULL,
    [FA_REFF_NO_07]                     NVARCHAR (250)  NULL,
    [UNIT_FROM]                         NVARCHAR (10)   NULL,
    [CATEGORY_TYPE]                     NVARCHAR (20)   NULL,
    [ASSET_NO]                          NVARCHAR (50)   NULL,
    [SUBVENTION_AMOUNT]                 DECIMAL (18, 2) NULL,
    [SPAF_AMOUNT]                       DECIMAL (18, 2) NULL,
    [MOBILIZATION_CITY_CODE]            NVARCHAR (50)   NULL,
    [MOBILIZATION_CITY_DESCRIPTION]     NVARCHAR (250)  NULL,
    [MOBILIZATION_PROVINCE_CODE]        NVARCHAR (50)   NULL,
    [MOBILIZATION_PROVINCE_DESCRIPTION] NVARCHAR (250)  NULL,
    [DELIVER_TO_ADDRESS]                NVARCHAR (4000) NULL,
    [DELIVER_TO_AREA_NO]                NVARCHAR (4)    NULL,
    [DELIVER_TO_PHONE_NO]               NVARCHAR (15)   NULL,
    [SETTLE_DATE]                       DATETIME        NULL,
    [JOB_STATUS]                        NVARCHAR (10)   CONSTRAINT [DF_OPL_INTERFACE_PAYMENT_REQUEST_JOB_STATUS] DEFAULT (N'HOLD') NULL,
    [FAILED_REMARKS]                    NVARCHAR (4000) NULL,
    [CRE_DATE]                          DATETIME        NOT NULL,
    [CRE_BY]                            NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                    NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                          DATETIME        NOT NULL,
    [MOD_BY]                            NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                    NVARCHAR (15)   NOT NULL,
    [MOBILIZATION_FA_CODE]              NVARCHAR (50)   NULL,
    [MOBILIZATION_FA_NAME]              NVARCHAR (250)  NULL,
    [ASSET_AMOUNT]                      DECIMAL (18, 2) NULL,
    [ASSET_DISCOUNT_AMOUNT]             DECIMAL (18, 2) NULL,
    [KAROSERI_AMOUNT]                   DECIMAL (18, 2) NULL,
    [KAROSERI_DISCOUNT_AMOUNT]          DECIMAL (18, 2) NULL,
    [ACCESORIES_AMOUNT]                 DECIMAL (18, 2) NULL,
    [ACCESORIES_DISCOUNT_AMOUNT]        DECIMAL (18, 2) NULL,
    [MOBILIZATION_AMOUNT]               DECIMAL (18, 2) NULL,
    [APPLICATION_NO]                    NVARCHAR (50)   NULL,
    [OTR_AMOUNT]                        DECIMAL (18, 2) NULL,
    [GPS_AMOUNT]                        DECIMAL (18, 2) NULL,
    [BUDGET_AMOUNT]                     DECIMAL (18, 2) NULL,
    [BBN_NAME]                          NVARCHAR (250)  NULL,
    [BBN_LOCATION]                      NVARCHAR (250)  NULL,
    [BBN_ADDRESS]                       NVARCHAR (4000) NULL,
    [BUILT_YEAR]                        NVARCHAR (4)    NULL,
    [ASSET_COLOUR]                      NVARCHAR (50)   NULL,
    CONSTRAINT [PK_OPL_INTERFACE_PURCHASE_REQUEST] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'informasi reference number ( plat no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_PURCHASE_REQUEST', @level2type = N'COLUMN', @level2name = N'FA_REFF_NO_01';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'informasi reference number ( chasis no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_PURCHASE_REQUEST', @level2type = N'COLUMN', @level2name = N'FA_REFF_NO_02';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'informasi reference number ( engine no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_PURCHASE_REQUEST', @level2type = N'COLUMN', @level2name = N'FA_REFF_NO_03';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'informasi reference number ( engine no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_PURCHASE_REQUEST', @level2type = N'COLUMN', @level2name = N'FA_REFF_NO_04';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'informasi reference number ( engine no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_PURCHASE_REQUEST', @level2type = N'COLUMN', @level2name = N'FA_REFF_NO_05';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'informasi reference number ( engine no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_PURCHASE_REQUEST', @level2type = N'COLUMN', @level2name = N'FA_REFF_NO_06';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'informasi reference number ( engine no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_PURCHASE_REQUEST', @level2type = N'COLUMN', @level2name = N'FA_REFF_NO_07';

