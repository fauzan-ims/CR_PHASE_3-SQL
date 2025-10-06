CREATE TABLE [dbo].[AGREEMENT_MAIN] (
    [AGREEMENT_NO]                        NVARCHAR (50)   NOT NULL,
    [AGREEMENT_EXTERNAL_NO]               NVARCHAR (50)   NULL,
    [APPLICATION_NO]                      NVARCHAR (50)   NOT NULL,
    [AGREEMENT_DATE]                      DATETIME        NOT NULL,
    [AGREEMENT_STATUS]                    NVARCHAR (10)   NOT NULL,
    [AGREEMENT_SUB_STATUS]                NVARCHAR (20)   CONSTRAINT [DF_AGREEMENT_MAIN_AGREEMENT_SUB_STATUS] DEFAULT ('') NOT NULL,
    [TERMINATION_DATE]                    DATETIME        NULL,
    [TERMINATION_STATUS]                  NVARCHAR (20)   NULL,
    [COLLECTION_STATUS]                   NVARCHAR (20)   CONSTRAINT [DF_AGREEMENT_MAIN_COLLECTION_STATUS] DEFAULT ('') NOT NULL,
    [BRANCH_CODE]                         NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]                         NVARCHAR (250)  NOT NULL,
    [INITIAL_BRANCH_CODE]                 NVARCHAR (50)   NOT NULL,
    [INITIAL_BRANCH_NAME]                 NVARCHAR (250)  NOT NULL,
    [CURRENCY_CODE]                       NVARCHAR (3)    CONSTRAINT [DF_AGREEMENT_MAIN_CURRENCY_CODE] DEFAULT (N'IDR') NOT NULL,
    [FACILITY_CODE]                       NVARCHAR (50)   NULL,
    [FACILITY_NAME]                       NVARCHAR (250)  NULL,
    [CLIENT_TYPE]                         NVARCHAR (10)   NOT NULL,
    [CLIENT_NO]                           NVARCHAR (50)   NOT NULL,
    [CLIENT_NAME]                         NVARCHAR (250)  NOT NULL,
    [TAX_SCHEME_CODE]                     NVARCHAR (50)   CONSTRAINT [DF_AGREEMENT_MAIN_TAX_SCHEME_CODE] DEFAULT ('') NULL,
    [PPN_PCT]                             DECIMAL (9, 6)  CONSTRAINT [DF_AGREEMENT_MAIN_PPN_PCT] DEFAULT ((0)) NOT NULL,
    [PPH_PCT]                             DECIMAL (9, 6)  CONSTRAINT [DF_AGREEMENT_MAIN_PPH_PCT] DEFAULT ((0)) NOT NULL,
    [OLD_AGREEMENT_NO]                    NVARCHAR (50)   NULL,
    [PAYMENT_PROMISE_DATE]                DATETIME        NULL,
    [MATURITY_CODE]                       NVARCHAR (50)   NULL,
    [IS_STOP_BILLING]                     NVARCHAR (1)    CONSTRAINT [DF_AGREEMENT_MAIN_IS_STOP_BILLING] DEFAULT ((0)) NOT NULL,
    [IS_PENDING_BILLING]                  NVARCHAR (1)    CONSTRAINT [DF_AGREEMENT_MAIN_IS_PENDING_BILLING] DEFAULT ((0)) NOT NULL,
    [PERIODE]                             INT             CONSTRAINT [DF_AGREEMENT_MAIN_PERIODE] DEFAULT ((0)) NULL,
    [BILLING_TYPE]                        NVARCHAR (50)   NULL,
    [CREDIT_TERM]                         INT             CONSTRAINT [DF_AGREEMENT_MAIN_CREDIT_TERM] DEFAULT ((0)) NULL,
    [FIRST_PAYMENT_TYPE]                  NVARCHAR (3)    CONSTRAINT [DF_AGREEMENT_MAIN_FIRST_PAYMENT_TYPE] DEFAULT (N'ADV') NULL,
    [IS_PURCHASE_REQUIREMENT_AFTER_LEASE] NVARCHAR (1)    NULL,
    [LEASE_OPTION]                        NVARCHAR (10)   NULL,
    [ROUND_TYPE]                          NVARCHAR (10)   NULL,
    [ROUND_AMOUNT]                        DECIMAL (18, 2) CONSTRAINT [DF_AGREEMENT_MAIN_ROUND_AMOUNT] DEFAULT ((0)) NULL,
    [MARKETING_CODE]                      NVARCHAR (50)   NULL,
    [MARKETING_NAME]                      NVARCHAR (250)  NULL,
    [OPL_STATUS]                          NVARCHAR (15)   NULL,
    [AGREEMENT_SIGN_DATE]                 DATETIME        NULL,
    [CRE_DATE]                            DATETIME        NOT NULL,
    [CRE_BY]                              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                            DATETIME        NOT NULL,
    [MOD_BY]                              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                      NVARCHAR (15)   NOT NULL,
    [CLIENT_ID]                           NVARCHAR (50)   NULL,
    [APPLICATION_NO_EXTERNAL]             NVARCHAR (50)   NULL,
    CONSTRAINT [PK_AGREEMENT_MAIN] PRIMARY KEY CLUSTERED ([AGREEMENT_NO] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_AGREEMENT_MAIN_20231026]
    ON [dbo].[AGREEMENT_MAIN]([AGREEMENT_STATUS] ASC)
    INCLUDE([AGREEMENT_EXTERNAL_NO], [AGREEMENT_DATE], [PERIODE]);


GO
CREATE NONCLUSTERED INDEX [IDX_AGREEMENT_MAIN_CLIENT_NO]
    ON [dbo].[AGREEMENT_MAIN]([CLIENT_NO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_AGREEMENT_MAIN_BRANCH_CODE]
    ON [dbo].[AGREEMENT_MAIN]([BRANCH_CODE] ASC)
    INCLUDE([CLIENT_NO], [CLIENT_NAME]);


GO
CREATE NONCLUSTERED INDEX [IDX_AGREEMENT_MAIN_20240123]
    ON [dbo].[AGREEMENT_MAIN]([AGREEMENT_EXTERNAL_NO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_AGREEMENT_MAIN_20241022]
    ON [dbo].[AGREEMENT_MAIN]([AGREEMENT_STATUS] ASC)
    INCLUDE([AGREEMENT_EXTERNAL_NO], [AGREEMENT_DATE], [BRANCH_CODE], [BRANCH_NAME], [CLIENT_NAME]);


GO
CREATE NONCLUSTERED INDEX [IDX_AGREEMENT_MAIN_AGREEMENT_STATUS_AGREEMENT_DATE_20250615]
    ON [dbo].[AGREEMENT_MAIN]([AGREEMENT_STATUS] ASC, [AGREEMENT_DATE] ASC)
    INCLUDE([BRANCH_CODE], [BRANCH_NAME], [PERIODE]);


GO
CREATE NONCLUSTERED INDEX [IDX_AGREEMENT_MAIN_AGREEMENT_STATUS_2025015]
    ON [dbo].[AGREEMENT_MAIN]([AGREEMENT_STATUS] ASC)
    INCLUDE([BRANCH_CODE], [CLIENT_NO], [CLIENT_NAME]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FULL, NON MAINTENENCE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'LEASE_OPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rounding type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'ROUND_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rounding amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN', @level2type = N'COLUMN', @level2name = N'ROUND_AMOUNT';

