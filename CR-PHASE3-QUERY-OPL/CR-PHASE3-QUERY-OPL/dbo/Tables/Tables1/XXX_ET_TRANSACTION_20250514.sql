CREATE TABLE [dbo].[XXX_ET_TRANSACTION_20250514] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [ET_CODE]              NVARCHAR (50)   NOT NULL,
    [TRANSACTION_CODE]     NVARCHAR (50)   NOT NULL,
    [TRANSACTION_AMOUNT]   DECIMAL (18, 2) NOT NULL,
    [DISC_PCT]             DECIMAL (9, 6)  NOT NULL,
    [DISC_AMOUNT]          DECIMAL (18, 2) NOT NULL,
    [TOTAL_AMOUNT]         DECIMAL (18, 2) NOT NULL,
    [ORDER_KEY]            INT             NOT NULL,
    [IS_AMOUNT_EDITABLE]   NVARCHAR (1)    NOT NULL,
    [IS_DISCOUNT_EDITABLE] NVARCHAR (1)    NOT NULL,
    [IS_TRANSACTION]       NVARCHAR (1)    NOT NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL
);

