CREATE TABLE [dbo].[SUSPEND_MERGER_DETAIL] (
    [ID]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [SUSPEND_MERGER_CODE] NVARCHAR (50)   NOT NULL,
    [SUSPEND_CODE]        NVARCHAR (50)   NOT NULL,
    [SUSPEND_AMOUNT]      DECIMAL (18, 2) CONSTRAINT [DF_MERGER_SUSPEND_DETAIL_SUSPEND_REMAINING_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_SUSPEND_MERGER_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SUSPEND_MERGER_DETAIL_SUSPEND_ALLOCATION] FOREIGN KEY ([SUSPEND_CODE]) REFERENCES [dbo].[SUSPEND_MAIN] ([CODE]),
    CONSTRAINT [FK_SUSPEND_MERGER_DETAIL_SUSPEND_MERGER] FOREIGN KEY ([SUSPEND_MERGER_CODE]) REFERENCES [dbo].[SUSPEND_MERGER] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MERGER_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode suspend merger pada data suspend merger detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MERGER_DETAIL', @level2type = N'COLUMN', @level2name = N'SUSPEND_MERGER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode suspend pada data suspend merger detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MERGER_DETAIL', @level2type = N'COLUMN', @level2name = N'SUSPEND_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai suspend pada data suspend merger detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SUSPEND_MERGER_DETAIL', @level2type = N'COLUMN', @level2name = N'SUSPEND_AMOUNT';

