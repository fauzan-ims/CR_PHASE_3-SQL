CREATE TABLE [dbo].[CLIENT_DOC] (
    [ID]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [CLIENT_CODE]    NVARCHAR (50) NOT NULL,
    [DOC_TYPE_CODE]  NVARCHAR (50) NOT NULL,
    [DOCUMENT_NO]    NVARCHAR (50) NOT NULL,
    [DOC_STATUS]     NVARCHAR (10) NOT NULL,
    [EFF_DATE]       DATETIME      NOT NULL,
    [EXP_DATE]       DATETIME      NULL,
    [IS_DEFAULT]     NVARCHAR (1)  NOT NULL,
    [CRE_DATE]       DATETIME      NOT NULL,
    [CRE_BY]         NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15) NOT NULL,
    [MOD_DATE]       DATETIME      NOT NULL,
    [MOD_BY]         NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_SYS_CLIENT_DOC_1] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_CLIENT_DOC_CLIENT_MAIN] FOREIGN KEY ([CLIENT_CODE]) REFERENCES [dbo].[CLIENT_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_CLIENT_DOC_SYS_GENERAL_SUBCODE] FOREIGN KEY ([DOC_TYPE_CODE]) REFERENCES [dbo].[SYS_GENERAL_SUBCODE] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : CDTYP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_DOC', @level2type = N'COLUMN', @level2name = N'DOC_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'IN NPROGRESS, EXIST', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_DOC', @level2type = N'COLUMN', @level2name = N'DOC_STATUS';

