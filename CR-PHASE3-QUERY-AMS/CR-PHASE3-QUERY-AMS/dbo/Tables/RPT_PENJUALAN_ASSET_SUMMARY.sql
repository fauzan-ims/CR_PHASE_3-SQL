CREATE TABLE [dbo].[RPT_PENJUALAN_ASSET_SUMMARY] (
    [USER_ID]                NVARCHAR (50)   NOT NULL,
    [TAHUN]                  NVARCHAR (4)    NULL,
    [SELL_TYPE]              NVARCHAR (50)   NULL,
    [TOTAL_UNIT]             INT             NULL,
    [SUM_OF_GAIN_OR_LOSS]    DECIMAL (18, 2) NULL,
    [PURCHASE_PRICE]         DECIMAL (18, 2) NULL,
    [SOLD_PRICE]             DECIMAL (18, 2) NULL,
    [SUM_AVG_PURCHASE_PRICE] DECIMAL (18, 2) NULL,
    [SUM_AVG_SOLD_PRICE]     DECIMAL (18, 2) NULL
);

