CREATE TABLE [dbo].[XXX_WITHOLDING_SETTLEMENT_AS_OF_AUG2024] (
    [ID]                  FLOAT (53)     NULL,
    [invoice_external_no] NVARCHAR (255) NULL,
    [invoice_date]        DATETIME       NULL,
    [faktur_no]           NVARCHAR (255) NULL,
    [description]         NVARCHAR (255) NULL,
    [total_pph_amount]    FLOAT (53)     NULL,
    [npwp_no]             NVARCHAR (255) NULL,
    [npwp_name]           NVARCHAR (255) NULL,
    [payment_reff_no]     FLOAT (53)     NULL,
    [payment_reff_date]   DATETIME       NULL
);

