CREATE TABLE [dbo].[RPT_GOOD_RECEIPT_NOTE] (
    [USER_ID]             NVARCHAR (50)  NULL,
    [REPORT_COMPANY]      NVARCHAR (250) NULL,
    [REPORT_TITLE]        NVARCHAR (250) NULL,
    [REPORT_IMAGE]        NVARCHAR (250) NULL,
    [GRN_CODE]            NVARCHAR (50)  NULL,
    [PURCHASE_ORDER_CODE] NVARCHAR (50)  NULL,
    [SUPPLIER_NAME]       NVARCHAR (250) NULL,
    [RECEIVE_DATE]        DATETIME       NULL,
    [CRE_DATE]            DATETIME       NULL,
    [CRE_BY]              NVARCHAR (15)  NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)  NULL,
    [MOD_DATE]            DATETIME       NULL,
    [MOD_BY]              NVARCHAR (15)  NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)  NULL
);

