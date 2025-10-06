CREATE TABLE [dbo].[AP_PAYMENT_REQUEST_DETAIL] (
    [ID]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [COMPANY_CODE]          NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PAYMENT_REQUEST_CODE]  NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [INVOICE_REGISTER_CODE] NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [IS_PAID]               NVARCHAR (1)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [UNIT_PRICE]            DECIMAL (18, 2) NULL,
    [PPN]                   DECIMAL (18, 2) NOT NULL,
    [PPH]                   DECIMAL (18, 2) NOT NULL,
    [DISCOUNT]              DECIMAL (18, 2) NULL,
    [PAYMENT_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [FEE]                   DECIMAL (18, 2) NOT NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_AP_PAYMENT_REQUEST_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);

