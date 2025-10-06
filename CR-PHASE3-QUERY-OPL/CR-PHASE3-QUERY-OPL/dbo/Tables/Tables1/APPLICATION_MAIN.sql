CREATE TABLE [dbo].[APPLICATION_MAIN] (
    [ID]                                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [APPLICATION_NO]                      NVARCHAR (50)   NOT NULL,
    [APPLICATION_EXTERNAL_NO]             NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]                         NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]                         NVARCHAR (250)  NOT NULL,
    [APPLICATION_DATE]                    DATETIME        NULL,
    [APPLICATION_STATUS]                  NVARCHAR (10)   NOT NULL,
    [LEVEL_STATUS]                        NVARCHAR (20)   NOT NULL,
    [APPLICATION_REMARKS]                 NVARCHAR (4000) NULL,
    [BRANCH_REGION_CODE]                  NVARCHAR (50)   NOT NULL,
    [BRANCH_REGION_NAME]                  NVARCHAR (250)  NOT NULL,
    [MARKETING_CODE]                      NVARCHAR (50)   NULL,
    [MARKETING_NAME]                      NVARCHAR (250)  NULL,
    [CLIENT_CODE]                         NVARCHAR (50)   NULL,
    [FACILITY_CODE]                       NVARCHAR (50)   NULL,
    [CURRENCY_CODE]                       NVARCHAR (3)    NULL,
    [MAIN_AGREEMENT_NO]                   NVARCHAR (50)   NULL,
    [AGREEMENT_NO]                        NVARCHAR (50)   NULL,
    [AGREEMENT_EXTERNAL_NO]               NVARCHAR (50)   NULL,
    [GOLIVE_DATE]                         DATETIME        NULL,
    [AGREEMENT_SIGN_DATE]                 DATETIME        NULL,
    [FIRST_INSTALLMENT_DATE]              DATETIME        NULL,
    [RENTAL_AMOUNT]                       DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_MAIN_RENTAL_AMOUNT] DEFAULT ((0)) NOT NULL,
    [IS_BLACKLIST_AREA]                   NVARCHAR (1)    CONSTRAINT [DF_APPLICATION_MAIN_IS_BLACKLIST_AREA] DEFAULT ((0)) NULL,
    [IS_BLACKLIST_JOB]                    NVARCHAR (1)    CONSTRAINT [DF_APPLICATION_MAIN_IS_BLACKLIST_JOB] DEFAULT ((0)) NULL,
    [WATCHLIST_STATUS]                    NVARCHAR (10)   NULL,
    [RETURN_COUNT]                        INT             CONSTRAINT [DF_APPLICATION_MAIN_RETURN_COUNT] DEFAULT ((0)) NOT NULL,
    [ASSET_ALLOCATION_STATUS]             NVARCHAR (10)   NULL,
    [TAX_SCHEME_CODE]                     NVARCHAR (50)   CONSTRAINT [DF_APPLICATION_MAIN_TAX_SCHEME_CODE] DEFAULT ('') NULL,
    [PPN_PCT]                             DECIMAL (9, 6)  CONSTRAINT [DF_APPLICATION_MAIN_PPN_PCT] DEFAULT ((0)) NOT NULL,
    [PPH_PCT]                             DECIMAL (9, 6)  CONSTRAINT [DF_APPLICATION_MAIN_PPH_PCT] DEFAULT ((0)) NOT NULL,
    [PERIODE]                             INT             CONSTRAINT [DF_APPLICATION_MAIN_PERIODE] DEFAULT ((0)) NOT NULL,
    [BILLING_TYPE]                        NVARCHAR (50)   NULL,
    [CREDIT_TERM]                         INT             CONSTRAINT [DF_APPLICATION_MAIN_PERIODE1] DEFAULT ((0)) NOT NULL,
    [FIRST_PAYMENT_TYPE]                  NVARCHAR (3)    CONSTRAINT [DF_APPLICATION_MAIN_CREDIT_TERM1] DEFAULT (N'ADV') NOT NULL,
    [IS_PURCHASE_REQUIREMENT_AFTER_LEASE] NVARCHAR (1)    NULL,
    [LEASE_OPTION]                        NVARCHAR (10)   CONSTRAINT [DF_APPLICATION_MAIN_LEASE_OPTION] DEFAULT (N'FULL') NULL,
    [ROUND_TYPE]                          NVARCHAR (10)   NULL,
    [ROUND_AMOUNT]                        DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_MAIN_ROUND_AMOUNT] DEFAULT ((0)) NULL,
    [CLIENT_NAME]                         NVARCHAR (250)  NULL,
    [CLIENT_PHONE_AREA]                   NVARCHAR (4)    NULL,
    [CLIENT_PHONE_NO]                     NVARCHAR (15)   NULL,
    [CLIENT_EMAIL]                        NVARCHAR (250)  NULL,
    [CLIENT_ADDRESS]                      NVARCHAR (4000) NULL,
    [IS_SIMULATION]                       NVARCHAR (1)    CONSTRAINT [DF_APPLICATION_MAIN_IS_SIMULATION] DEFAULT ((1)) NULL,
    [CRE_DATE]                            DATETIME        NOT NULL,
    [CRE_BY]                              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                            DATETIME        NOT NULL,
    [MOD_BY]                              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                      NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_APPLICATION_MAIN] PRIMARY KEY CLUSTERED ([APPLICATION_NO] ASC),
    CONSTRAINT [FK_APPLICATION_MAIN_CLIENT_MAIN] FOREIGN KEY ([CLIENT_CODE]) REFERENCES [dbo].[CLIENT_MAIN] ([CODE]) ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor Aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_MAIN', @level2type = N'COLUMN', @level2name = N'APPLICATION_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor Aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_MAIN', @level2type = N'COLUMN', @level2name = N'MAIN_AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor Aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor Aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_EXTERNAL_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FULL, NON MAINTENENCE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_MAIN', @level2type = N'COLUMN', @level2name = N'LEASE_OPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rounding type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_MAIN', @level2type = N'COLUMN', @level2name = N'ROUND_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rounding amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_MAIN', @level2type = N'COLUMN', @level2name = N'ROUND_AMOUNT';

