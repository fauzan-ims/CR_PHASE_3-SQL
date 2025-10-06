CREATE TABLE [dbo].[APPLICATION_APPROVAL_COMMENT] (
    [ID]             BIGINT          IDENTITY (1, 1) NOT NULL,
    [APPLICATION_NO] NVARCHAR (50)   NOT NULL,
    [LAST_STATUS]    NVARCHAR (10)   NOT NULL,
    [LEVEL_STATUS]   NVARCHAR (20)   NOT NULL,
    [CYCLE]          INT             CONSTRAINT [DF_APPLICATION_APPROVAL_COMMENT_CYCLE] DEFAULT ((0)) NOT NULL,
    [REMARKS]        NVARCHAR (4000) NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_APPLICATION_APPROVE_COMMENT_1] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_APPLICATION_APPROVAL_COMMENT_APPLICATION_MAIN] FOREIGN KEY ([APPLICATION_NO]) REFERENCES [dbo].[APPLICATION_MAIN] ([APPLICATION_NO]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto Generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_APPROVAL_COMMENT', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_APPROVAL_COMMENT', @level2type = N'COLUMN', @level2name = N'APPLICATION_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada komentar approval tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_APPROVAL_COMMENT', @level2type = N'COLUMN', @level2name = N'REMARKS';

