CREATE TABLE [dbo].[SUSPEND_REVENUE_DETAIL] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [SUSPEND_REVENUE_CODE] NVARCHAR (50)   NOT NULL,
    [SUSPEND_CODE]         NVARCHAR (50)   NOT NULL,
    [SUSPEND_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_SUSPEND_REVENUE_DETAIL_DEPOSIT_AMOUNT] DEFAULT ((0)) NOT NULL,
    [REVENUE_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_SUSPEND_REVENUE_DETAIL_REVENUE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_SUSPEND_REVENUE_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SUSPEND_REVENUE_DETAIL_SUSPEND_MAIN] FOREIGN KEY ([SUSPEND_CODE]) REFERENCES [dbo].[SUSPEND_MAIN] ([CODE]),
    CONSTRAINT [FK_SUSPEND_REVENUE_DETAIL_SUSPEND_REVENUE] FOREIGN KEY ([SUSPEND_REVENUE_CODE]) REFERENCES [dbo].[SUSPEND_REVENUE] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_REVENUE_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode suspend revenue pada data suspend revenue detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_REVENUE_DETAIL', @level2type = N'COLUMN', @level2name = N'SUSPEND_REVENUE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode suspend pada data suspend revenue detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_REVENUE_DETAIL', @level2type = N'COLUMN', @level2name = N'SUSPEND_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai suspend pada data suspend revenue detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_REVENUE_DETAIL', @level2type = N'COLUMN', @level2name = N'SUSPEND_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai suspend yang diakui pada data suspend revenue detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_REVENUE_DETAIL', @level2type = N'COLUMN', @level2name = N'REVENUE_AMOUNT';

