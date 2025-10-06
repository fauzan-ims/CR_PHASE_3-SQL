CREATE TABLE [dbo].[RPT_VENDOR_OPL] (
    [USER_ID]             NVARCHAR (50)   NOT NULL,
    [REPORT_COMPANY]      NVARCHAR (250)  NOT NULL,
    [REPORT_TITLE]        NVARCHAR (250)  NOT NULL,
    [REPORT_IMAGE]        NVARCHAR (50)   NULL,
    [FROM_DATE]           DATETIME        NULL,
    [TO_DATE]             DATETIME        NULL,
    [NAME]                NVARCHAR (250)  NULL,
    [ORDER_NO]            NVARCHAR (50)   NULL,
    [SKD_OR_AGREEMENT_NO] NVARCHAR (50)   NULL,
    [MEMO_NO]             NVARCHAR (50)   NULL,
    [MEMO_DATE]           DATETIME        NULL,
    [LESSEE]              NVARCHAR (250)  NULL,
    [SUPPLIER]            NVARCHAR (250)  NULL,
    [UNIT]                INT             NULL,
    [TYPE_OFF_PAYMENT]    NVARCHAR (250)  NULL,
    [PLAT_NO]             NVARCHAR (50)   NULL,
    [PRICE_INC_VAT]       DECIMAL (18, 2) NULL,
    [DISBURSE_DATE]       DATETIME        NULL,
    [LESSEE_N]            NVARCHAR (50)   NULL,
    [IS_CONDITION]        NVARCHAR (1)    NULL
);

