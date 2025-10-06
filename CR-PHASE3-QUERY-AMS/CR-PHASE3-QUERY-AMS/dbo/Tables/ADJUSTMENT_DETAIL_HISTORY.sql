CREATE TABLE [dbo].[ADJUSTMENT_DETAIL_HISTORY] (
    [ID]                         BIGINT          IDENTITY (1, 1) NOT NULL,
    [ADJUSTMENT_CODE]            NVARCHAR (50)   NOT NULL,
    [ADJUSMENT_TRANSACTION_CODE] NVARCHAR (50)   NOT NULL,
    [AMOUNT]                     DECIMAL (18, 2) NOT NULL,
    [CURRENCY_CODE]              NVARCHAR (50)   NOT NULL,
    [CRE_DATE]                   DATETIME        NOT NULL,
    [CRE_BY]                     NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                   DATETIME        NOT NULL,
    [MOD_BY]                     NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_ADJUSTMENT_DETAIL_HISTORY] PRIMARY KEY CLUSTERED ([ID] ASC)
);

