CREATE TABLE [dbo].[XXX_SPAF_ASSET_20240220] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [DATE]                  DATETIME        NOT NULL,
    [FA_CODE]               NVARCHAR (50)   NOT NULL,
    [SPAF_PCT]              DECIMAL (9, 6)  NOT NULL,
    [SPAF_AMOUNT]           DECIMAL (18, 2) NULL,
    [SUBVENTION_AMOUNT]     DECIMAL (18, 2) NULL,
    [VALIDATION_STATUS]     NVARCHAR (10)   NULL,
    [VALIDATION_DATE]       DATETIME        NULL,
    [VALIDATION_REMARK]     NVARCHAR (4000) NULL,
    [CLAIM_CODE]            NVARCHAR (50)   NULL,
    [CLAIM_TYPE]            NVARCHAR (25)   NULL,
    [SPAF_RECEIPT_NO]       NVARCHAR (50)   NULL,
    [SUBVENTION_RECEIPT_NO] NVARCHAR (50)   NULL,
    [RECEIPT_DATE]          DATETIME        NULL,
    [STATUS]                NVARCHAR (50)   NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (50)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (50)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (50)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (50)   NOT NULL
);

