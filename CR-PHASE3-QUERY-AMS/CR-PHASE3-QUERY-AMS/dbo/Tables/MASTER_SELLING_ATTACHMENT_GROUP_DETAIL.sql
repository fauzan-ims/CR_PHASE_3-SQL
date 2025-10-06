CREATE TABLE [dbo].[MASTER_SELLING_ATTACHMENT_GROUP_DETAIL] (
    [ID]                  BIGINT        IDENTITY (1, 1) NOT NULL,
    [DOCUMENT_GROUP_CODE] NVARCHAR (50) NOT NULL,
    [GENERAL_DOC_CODE]    NVARCHAR (50) NOT NULL,
    [IS_REQUIRED]         NVARCHAR (1)  NOT NULL,
    [CRE_DATE]            DATETIME      NOT NULL,
    [CRE_BY]              NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15) NOT NULL,
    [MOD_DATE]            DATETIME      NOT NULL,
    [MOD_BY]              NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_MASTER_SELLING_ATTACHMENT_GROUP_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode document group', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP_DETAIL', @level2type = N'COLUMN', @level2name = N'DOCUMENT_GROUP_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode general document atas data tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP_DETAIL', @level2type = N'COLUMN', @level2name = N'GENERAL_DOC_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari dokumen tersebut, apakah dokumen tersebut wajib untuk dipenuhi?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_SELLING_ATTACHMENT_GROUP_DETAIL', @level2type = N'COLUMN', @level2name = N'IS_REQUIRED';

