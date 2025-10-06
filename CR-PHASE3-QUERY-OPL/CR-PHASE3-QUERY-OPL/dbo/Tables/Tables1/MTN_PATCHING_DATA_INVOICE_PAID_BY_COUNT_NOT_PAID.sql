CREATE TABLE [dbo].[MTN_PATCHING_DATA_INVOICE_PAID_BY_COUNT_NOT_PAID] (
    [agreement_external_no] NVARCHAR (100)  NULL,
    [invoice_no]            NVARCHAR (100)  NULL,
    [billing_no]            INT             NULL,
    [client_name]           NVARCHAR (400)  NULL,
    [invoice_date]          DATETIME        NULL,
    [ar_amount]             DECIMAL (18, 2) NULL,
    [payment_amount]        DECIMAL (18, 2) NULL,
    [outstanding_ar]        DECIMAL (18, 2) NULL,
    [STATUS]                VARCHAR (1)     NOT NULL
);

