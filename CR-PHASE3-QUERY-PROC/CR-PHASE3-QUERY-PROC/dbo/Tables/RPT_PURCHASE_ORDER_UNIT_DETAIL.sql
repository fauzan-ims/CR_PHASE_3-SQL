CREATE TABLE [dbo].[RPT_PURCHASE_ORDER_UNIT_DETAIL] (
    [USER_ID]        NVARCHAR (50)   NOT NULL,
    [DESKRIPSI_ITEM] NVARCHAR (4000) NULL,
    [JUMLAH]         INT             NULL,
    [HARGA]          DECIMAL (18, 2) NULL,
    [TOTAL]          DECIMAL (18, 2) NULL,
    [TERBILANG]      NVARCHAR (250)  NULL
);

