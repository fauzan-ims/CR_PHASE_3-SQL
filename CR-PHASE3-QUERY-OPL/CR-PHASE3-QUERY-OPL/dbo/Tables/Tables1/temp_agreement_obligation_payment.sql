CREATE TABLE [dbo].[temp_agreement_obligation_payment] (
    [ID]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [OBLIGATION_CODE]     NVARCHAR (50)   NOT NULL,
    [AGREEMENT_NO]        NVARCHAR (50)   NOT NULL,
    [ASSET_NO]            NVARCHAR (50)   NOT NULL,
    [INVOICE_NO]          NVARCHAR (50)   NOT NULL,
    [INSTALLMENT_NO]      INT             NULL,
    [PAYMENT_DATE]        DATETIME        NOT NULL,
    [VALUE_DATE]          DATETIME        NOT NULL,
    [PAYMENT_SOURCE_TYPE] NVARCHAR (50)   NULL,
    [PAYMENT_SOURCE_NO]   NVARCHAR (50)   NOT NULL,
    [PAYMENT_AMOUNT]      DECIMAL (18, 2) NOT NULL,
    [IS_WAIVE]            NVARCHAR (1)    NOT NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL
);

