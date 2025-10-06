CREATE TABLE [dbo].[XXX_RPT_EXT_PROJECTION_DATA_20240810] (
    [ID]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [COA_ACCOUNT]           NVARCHAR (50)   NULL,
    [TIME]                  NVARCHAR (50)   NULL,
    [SEQUENCE]              NVARCHAR (50)   NULL,
    [ASSET_MODEL]           NVARCHAR (50)   NULL,
    [ASSET_BRAND]           NVARCHAR (50)   NULL,
    [ASSET_BRAND_TYPE]      NVARCHAR (50)   NULL,
    [ASSET_TYPE]            NVARCHAR (50)   NULL,
    [ASSET_BRAND_TYPE_NAME] NVARCHAR (250)  NULL,
    [ASSET_CONDITION]       NVARCHAR (50)   NULL,
    [AGREEMENT_ID]          NVARCHAR (50)   NULL,
    [AMOUNT]                DECIMAL (18, 2) NULL,
    [AS_OF]                 DATETIME        NULL,
    [CREATE_DATE]           DATETIME        NULL,
    [CREATE_TIME]           DATETIME        NULL,
    [CRE_DATE]              DATETIME        NULL,
    [CRE_BY]                NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NULL,
    [MOD_DATE]              DATETIME        NULL,
    [MOD_BY]                NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NULL
);

