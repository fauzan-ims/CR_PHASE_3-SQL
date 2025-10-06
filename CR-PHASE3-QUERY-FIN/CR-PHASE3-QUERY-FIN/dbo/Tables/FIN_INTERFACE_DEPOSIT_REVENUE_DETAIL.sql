CREATE TABLE [dbo].[FIN_INTERFACE_DEPOSIT_REVENUE_DETAIL] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [DEPOSIT_REVENUE_CODE] NVARCHAR (50)   NOT NULL,
    [DEPOSIT_CODE]         NVARCHAR (50)   NOT NULL,
    [DEPOSIT_TYPE]         NVARCHAR (15)   NULL,
    [DEPOSIT_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_FIN_INTERFACE_DEPOSIT_REVENUE_DETAIL_DEPOSIT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [REVENUE_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_FIN_INTERFACE_DEPOSIT_REVENUE_DETAIL_REVENUE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_FIN_INTERFACE_DEPOSIT_REVENUE_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_REVENUE_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode deposit revenue pada data deposit revenue detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_REVENUE_DETAIL', @level2type = N'COLUMN', @level2name = N'DEPOSIT_REVENUE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode deposit pada data deposit revenue detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_REVENUE_DETAIL', @level2type = N'COLUMN', @level2name = N'DEPOSIT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai deposit pada data deposit revenue detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_REVENUE_DETAIL', @level2type = N'COLUMN', @level2name = N'DEPOSIT_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai yang di revenue pada data deposit revenue detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FIN_INTERFACE_DEPOSIT_REVENUE_DETAIL', @level2type = N'COLUMN', @level2name = N'REVENUE_AMOUNT';

