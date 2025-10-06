CREATE TABLE [dbo].[CLIENT_BLACKLIST] (
    [CODE]                           NVARCHAR (50)   NOT NULL,
    [SOURCE]                         NVARCHAR (250)  NOT NULL,
    [CLIENT_TYPE]                    NVARCHAR (10)   NOT NULL,
    [BLACKLIST_TYPE]                 NVARCHAR (10)   NULL,
    [PERSONAL_NATIONALITY_TYPE_CODE] NVARCHAR (3)    NULL,
    [PERSONAL_DOC_TYPE_CODE]         NVARCHAR (50)   NULL,
    [PERSONAL_ID_NO]                 NVARCHAR (50)   NULL,
    [PERSONAL_NAME]                  NVARCHAR (250)  NULL,
    [PERSONAL_ALIAS_NAME]            NVARCHAR (250)  NULL,
    [PERSONAL_MOTHER_MAIDEN_NAME]    NVARCHAR (250)  NULL,
    [PERSONAL_DOB]                   DATETIME        NULL,
    [CORPORATE_NAME]                 NVARCHAR (250)  NULL,
    [CORPORATE_TAX_FILE_NO]          NVARCHAR (50)   NULL,
    [CORPORATE_EST_DATE]             DATETIME        NULL,
    [ENTRY_DATE]                     DATETIME        NOT NULL,
    [ENTRY_REMARKS]                  NVARCHAR (4000) NOT NULL,
    [EXIT_DATE]                      DATETIME        NULL,
    [EXIT_REMARKS]                   NVARCHAR (4000) NULL,
    [IS_ACTIVE]                      NVARCHAR (1)    NOT NULL,
    [CRE_DATE]                       DATETIME        NOT NULL,
    [CRE_BY]                         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                       DATETIME        NOT NULL,
    [MOD_BY]                         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_CLIENT_BLACKLIST] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PERSONAL, CORPORATE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_BLACKLIST', @level2type = N'COLUMN', @level2name = N'CLIENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PERSONAL, CORPORATE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_BLACKLIST', @level2type = N'COLUMN', @level2name = N'PERSONAL_NATIONALITY_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KTP, KTA
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_BLACKLIST', @level2type = N'COLUMN', @level2name = N'PERSONAL_DOC_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'WARNING, NEGATIVE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_BLACKLIST', @level2type = N'COLUMN', @level2name = N'PERSONAL_ID_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PERSONAL, CORPORATE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_BLACKLIST', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

