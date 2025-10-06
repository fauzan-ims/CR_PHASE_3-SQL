CREATE TABLE [dbo].[XXX_TAX2_JUNI] (
    [Payment_request_ams]      NVARCHAR (50)   NOT NULL,
    [PAYMENT_SOURCE_NO]        NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]             NVARCHAR (50)   NOT NULL,
    [agreement]                NVARCHAR (50)   NULL,
    [EXT_TAX_NUMBER]           NVARCHAR (50)   NULL,
    [Faktur_register_main]     NVARCHAR (50)   NULL,
    [Invoice_register_main]    NVARCHAR (50)   NULL,
    [Faktur_WO]                NVARCHAR (50)   NULL,
    [Invoice_WO]               NVARCHAR (50)   NULL,
    [PAYMENT_TRANSACTION_CODE] NVARCHAR (50)   NULL,
    [EXT_DESCRIPTION]          NVARCHAR (4000) NULL
);

