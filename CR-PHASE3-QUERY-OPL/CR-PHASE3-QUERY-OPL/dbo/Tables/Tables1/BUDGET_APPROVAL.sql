CREATE TABLE [dbo].[BUDGET_APPROVAL] (
    [CODE]           NVARCHAR (50) NOT NULL,
    [ASSET_NO]       NVARCHAR (50) NOT NULL,
    [STATUS]         NVARCHAR (10) NOT NULL,
    [DATE]           DATETIME      NOT NULL,
    [CRE_DATE]       DATETIME      NOT NULL,
    [CRE_BY]         NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15) NOT NULL,
    [MOD_DATE]       DATETIME      NOT NULL,
    [MOD_BY]         NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_BUDGET_APPROVAL] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_BUDGET_APPROVAL_APPLICATION_ASSET] FOREIGN KEY ([ASSET_NO]) REFERENCES [dbo].[APPLICATION_ASSET] ([ASSET_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BUDGET_APPROVAL', @level2type = N'COLUMN', @level2name = N'ASSET_NO';

