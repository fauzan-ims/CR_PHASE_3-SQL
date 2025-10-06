CREATE TABLE [dbo].[ASSET_AGING] (
    [ID]                         BIGINT          IDENTITY (1, 1) NOT NULL,
    [AGING_DATE]                 DATETIME        NOT NULL,
    [CODE]                       NVARCHAR (50)   NOT NULL,
    [ITEM_CODE]                  NVARCHAR (50)   NOT NULL,
    [STATUS]                     NVARCHAR (50)   NOT NULL,
    [FISICAL_STATUS]             NVARCHAR (25)   NULL,
    [INSURANCE_STATUS]           NVARCHAR (10)   NULL,
    [CLAIM_STATUS]               NVARCHAR (10)   NULL,
    [RENTAL_STATUS]              NVARCHAR (25)   NULL,
    [RENTAL_REFF_NO]             NVARCHAR (50)   NULL,
    [RESERVED_BY]                NVARCHAR (50)   NULL,
    [RESERVED_DATE]              DATETIME        NULL,
    [PURCHASE_PRICE]             DECIMAL (18, 2) NOT NULL,
    [ORIGINAL_PRICE]             DECIMAL (18, 2) NOT NULL,
    [SALE_AMOUNT]                DECIMAL (18, 2) NULL,
    [SALE_DATE]                  DATETIME        NULL,
    [DISPOSAL_DATE]              DATETIME        NULL,
    [PIC_CODE]                   NVARCHAR (50)   NULL,
    [PIC_NAME]                   NVARCHAR (250)  NULL,
    [RESIDUAL_VALUE]             DECIMAL (18, 2) NULL,
    [DEPRE_CATEGORY_COMM_CODE]   NVARCHAR (50)   NOT NULL,
    [TOTAL_DEPRE_COMM]           DECIMAL (18, 2) NOT NULL,
    [DEPRE_PERIOD_COMM]          NVARCHAR (6)    NULL,
    [NET_BOOK_VALUE_COMM]        DECIMAL (18, 2) NOT NULL,
    [DEPRE_CATEGORY_FISCAL_CODE] NVARCHAR (50)   NOT NULL,
    [TOTAL_DEPRE_FISCAL]         DECIMAL (18, 2) NOT NULL,
    [DEPRE_PERIOD_FISCAL]        NVARCHAR (6)    NULL,
    [NET_BOOK_VALUE_FISCAL]      DECIMAL (18, 2) NOT NULL,
    [IS_RENTAL]                  NVARCHAR (1)    NULL,
    [IS_MAINTENANCE]             NVARCHAR (1)    NULL,
    [USE_LIFE]                   NVARCHAR (15)   NULL,
    [ASSET_PURPOSE]              NVARCHAR (50)   NULL,
    [ASSET_FROM]                 NVARCHAR (50)   NULL,
    [PARKING_LOCATION]           NVARCHAR (250)  NULL,
    [PROCESS_STATUS]             NVARCHAR (50)   NULL,
    [AGREEMENT_NO]               NVARCHAR (50)   NULL,
    [CLIENT_NAME]                NVARCHAR (250)  NULL,
    [START_PERIOD_DATE]          DATETIME        NULL,
    [END_PERIOD_DATE]            DATETIME        NULL,
    [WO_NO]                      NVARCHAR (50)   NULL,
    [CRE_DATE]                   DATETIME        NOT NULL,
    [CRE_BY]                     NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                   DATETIME        NOT NULL,
    [MOD_BY]                     NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK__ASSET_AG__3214EC274B9E6B06] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_ASSET_AGING_RENTAL_STATUS_STATUS_20250615]
    ON [dbo].[ASSET_AGING]([RENTAL_STATUS] ASC, [STATUS] ASC)
    INCLUDE([AGING_DATE], [PROCESS_STATUS]);


GO
CREATE NONCLUSTERED INDEX [IDX_ASSET_AGING_STATUS_20250615]
    ON [dbo].[ASSET_AGING]([STATUS] ASC)
    INCLUDE([AGING_DATE], [CODE]);

