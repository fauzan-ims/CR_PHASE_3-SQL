CREATE TABLE [dbo].[RPT_GOOD_RECEIPT_NOTE_DETAIL] (
    [USER_ID]                NVARCHAR (50)   NULL,
    [REPORT_COMPANY]         NVARCHAR (250)  NULL,
    [REPORT_TITLE]           NVARCHAR (250)  NULL,
    [REPORT_IMAGE]           NVARCHAR (250)  NULL,
    [GOOD_RECEIPT_NOTE_CODE] NVARCHAR (50)   NULL,
    [ITEM_CODE]              NVARCHAR (50)   NULL,
    [ITEM_NAME]              NVARCHAR (250)  NULL,
    [UOM_NAME]               NVARCHAR (250)  NULL,
    [PRICE_AMOUNT]           DECIMAL (18, 2) NULL,
    [PO_QUANTITY]            DECIMAL (18, 2) NULL,
    [RECEIVE_QUANTITY]       DECIMAL (18, 2) NULL,
    [CRE_DATE]               DATETIME        NULL,
    [CRE_BY]                 NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NULL,
    [MOD_DATE]               DATETIME        NULL,
    [MOD_BY]                 NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NULL,
    [CHASSIS_NO]             NVARCHAR (50)   NULL,
    [ENGINE_NO]              NVARCHAR (50)   NULL,
    [PLAT_NO]                NVARCHAR (50)   NULL
);

