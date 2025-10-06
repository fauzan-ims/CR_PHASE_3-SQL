CREATE TABLE [dbo].[ADJUSTMENT_DETAIL] (
    [ID]                         BIGINT          IDENTITY (1, 1) NOT NULL,
    [ADJUSTMENT_CODE]            NVARCHAR (50)   NOT NULL,
    [ADJUSMENT_TRANSACTION_CODE] NVARCHAR (250)  NULL,
    [ADJUSTMENT_DESCRIPTION]     NVARCHAR (250)  NULL,
    [AMOUNT]                     DECIMAL (18, 2) NOT NULL,
    [CRE_DATE]                   DATETIME        NOT NULL,
    [CRE_BY]                     NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                   DATETIME        NOT NULL,
    [MOD_BY]                     NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    [UOM]                        NVARCHAR (15)   NULL,
    [QUANTITY]                   INT             NULL,
    CONSTRAINT [PK_ADJUSTMENT_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);

