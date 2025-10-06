CREATE TABLE [dbo].[TEMP_ASSET_FOR_UPDATE] (
    [asset_code]     NVARCHAR (50)   NULL,
    [price_amount]   DECIMAL (18, 2) NULL,
    [original_price] DECIMAL (18, 2) NULL,
    [ppn]            DECIMAL (18, 2) NULL,
    [discount]       DECIMAL (18, 2) NULL,
    [purchase_date]  DATETIME        NULL,
    [status]         NVARCHAR (50)   NULL,
    [PIC]            NVARCHAR (50)   NULL,
    [DATE]           DATETIME        NULL,
    [REMARK]         NVARCHAR (250)  NULL
);

