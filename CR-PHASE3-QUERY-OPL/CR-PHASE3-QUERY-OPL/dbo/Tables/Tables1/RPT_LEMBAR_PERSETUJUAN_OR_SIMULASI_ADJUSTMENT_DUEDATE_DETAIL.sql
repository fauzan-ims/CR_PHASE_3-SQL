CREATE TABLE [dbo].[RPT_LEMBAR_PERSETUJUAN_OR_SIMULASI_ADJUSTMENT_DUEDATE_DETAIL] (
    [USER_ID]                  NVARCHAR (50)   NULL,
    [ASSET_NAME]               NVARCHAR (250)  NULL,
    [PLAT_NO]                  NVARCHAR (50)   NULL,
    [RENTAL_AMOUNT]            DECIMAL (18, 2) NULL,
    [END_PERIODE]              DATETIME        NULL,
    [DATE_ADJUSTMENT_DUE_DATE] DATETIME        NULL,
    [protate_rental_akhir]     DECIMAL (18, 2) NULL,
    [ASSET_NO]                 NVARCHAR (50)   NULL
);

