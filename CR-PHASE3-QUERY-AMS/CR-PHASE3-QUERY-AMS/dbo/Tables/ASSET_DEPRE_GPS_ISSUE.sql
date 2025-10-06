CREATE TABLE [dbo].[ASSET_DEPRE_GPS_ISSUE] (
    [ID]                  BIGINT          NULL,
    [ASSET_CODE]          NVARCHAR (50)   NULL,
    [DEPRECIATION_DATE]   DATETIME        NULL,
    [ORIGINAL_PRICE]      DECIMAL (18, 2) NULL,
    [DEPRECIATION_AMOUNT] DECIMAL (18, 2) NULL,
    [ACCUM_DEPRE_AMOUNT]  DECIMAL (18, 2) NULL,
    [NET_BOOK_VALUE]      DECIMAL (18, 2) NULL,
    [TRANSACTION_CODE]    NVARCHAR (50)   NULL,
    [CRE_DATE]            DATETIME        NULL,
    [CRE_BY]              NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NULL,
    [MOD_DATE]            DATETIME        NULL,
    [MOD_BY]              NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NULL
);

