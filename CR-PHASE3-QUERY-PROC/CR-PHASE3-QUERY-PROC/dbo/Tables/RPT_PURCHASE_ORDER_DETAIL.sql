﻿CREATE TABLE [dbo].[RPT_PURCHASE_ORDER_DETAIL] (
    [USER_ID]        NVARCHAR (50)   NULL,
    [REPORT_COMPANY] NVARCHAR (250)  NULL,
    [REPORT_TITLE]   NVARCHAR (250)  NULL,
    [REPORT_IMAGE]   NVARCHAR (250)  NULL,
    [CODE]           NVARCHAR (50)   NOT NULL,
    [ITEM_NAME]      NVARCHAR (250)  NULL,
    [UOM_NAME]       NVARCHAR (250)  NULL,
    [QUANTITY]       INT             NULL,
    [PPN]            DECIMAL (18, 2) NULL,
    [PPH]            DECIMAL (18, 2) NULL,
    [PRICE_AMOUNT]   DECIMAL (18, 2) NULL,
    [TOTAL_AMOUNT]   DECIMAL (18, 2) NULL,
    [DISCOUNT]       DECIMAL (18, 2) NULL,
    [CURRENCY]       NVARCHAR (20)   NULL,
    [CRE_DATE]       DATETIME        NULL,
    [CRE_BY]         NVARCHAR (50)   NULL,
    [CRE_IP_ADDRESS] NVARCHAR (50)   NULL,
    [MOD_DATE]       DATETIME        NULL,
    [MOD_BY]         NVARCHAR (50)   NULL,
    [MOD_IP_ADDRESS] NVARCHAR (50)   NULL
);

