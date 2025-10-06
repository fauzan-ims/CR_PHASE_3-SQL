CREATE TABLE [dbo].[OPL_INTERFACE_CLIENT_PERSONAL_INFO] (
    [CLIENT_CODE]             NVARCHAR (50)  NOT NULL,
    [FULL_NAME]               NVARCHAR (250) NOT NULL,
    [ALIAS_NAME]              NVARCHAR (250) NOT NULL,
    [MOTHER_MAIDEN_NAME]      NVARCHAR (250) NOT NULL,
    [PLACE_OF_BIRTH]          NVARCHAR (250) NOT NULL,
    [DATE_OF_BIRTH]           DATETIME       NOT NULL,
    [RELIGION_TYPE_CODE]      NVARCHAR (50)  NOT NULL,
    [GENDER_CODE]             NVARCHAR (50)  NOT NULL,
    [EMAIL]                   NVARCHAR (50)  NULL,
    [AREA_MOBILE_NO]          NVARCHAR (4)   NOT NULL,
    [MOBILE_NO]               NVARCHAR (15)  NOT NULL,
    [NATIONALITY_TYPE_CODE]   NVARCHAR (50)  NOT NULL,
    [SALUTATION_PREFIX_CODE]  NVARCHAR (50)  NULL,
    [SALUTATION_POSTFIX_CODE] NVARCHAR (50)  NULL,
    [EDUCATION_TYPE_CODE]     NVARCHAR (50)  NULL,
    [MARRIAGE_TYPE_CODE]      NVARCHAR (50)  NOT NULL,
    [DEPENDENT_COUNT]         INT            NOT NULL,
    [CRE_DATE]                DATETIME       NOT NULL,
    [CRE_BY]                  NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]          NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                DATETIME       NOT NULL,
    [MOD_BY]                  NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]          NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_OPL_INTERFACE_CLIENT_PERSONAL_INFO] PRIMARY KEY CLUSTERED ([CLIENT_CODE] ASC),
    CONSTRAINT [FK_OPL_INTERFACE_CLIENT_PERSONAL_INFO_OPL_INTERFACE_CLIENT_MAIN] FOREIGN KEY ([CLIENT_CODE]) REFERENCES [dbo].[OPL_INTERFACE_CLIENT_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_OPL_INTERFACE_CLIENT_PERSONAL_INFO_SYS_GENERAL_SUBCODE] FOREIGN KEY ([RELIGION_TYPE_CODE]) REFERENCES [dbo].[SYS_GENERAL_SUBCODE] ([CODE]),
    CONSTRAINT [FK_OPL_INTERFACE_CLIENT_PERSONAL_INFO_SYS_GENERAL_SUBCODE1] FOREIGN KEY ([GENDER_CODE]) REFERENCES [dbo].[SYS_GENERAL_SUBCODE] ([CODE]),
    CONSTRAINT [FK_OPL_INTERFACE_CLIENT_PERSONAL_INFO_SYS_GENERAL_SUBCODE3] FOREIGN KEY ([SALUTATION_PREFIX_CODE]) REFERENCES [dbo].[SYS_GENERAL_SUBCODE] ([CODE]),
    CONSTRAINT [FK_OPL_INTERFACE_CLIENT_PERSONAL_INFO_SYS_GENERAL_SUBCODE4] FOREIGN KEY ([SALUTATION_POSTFIX_CODE]) REFERENCES [dbo].[SYS_GENERAL_SUBCODE] ([CODE]),
    CONSTRAINT [FK_OPL_INTERFACE_CLIENT_PERSONAL_INFO_SYS_GENERAL_SUBCODE5] FOREIGN KEY ([MARRIAGE_TYPE_CODE]) REFERENCES [dbo].[SYS_GENERAL_SUBCODE] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : RLGION', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_CLIENT_PERSONAL_INFO', @level2type = N'COLUMN', @level2name = N'RELIGION_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : GNDR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_CLIENT_PERSONAL_INFO', @level2type = N'COLUMN', @level2name = N'GENDER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : NATTP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_CLIENT_PERSONAL_INFO', @level2type = N'COLUMN', @level2name = N'NATIONALITY_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : CSPFX', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_CLIENT_PERSONAL_INFO', @level2type = N'COLUMN', @level2name = N'SALUTATION_PREFIX_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : CSPPX', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_CLIENT_PERSONAL_INFO', @level2type = N'COLUMN', @level2name = N'SALUTATION_POSTFIX_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : EDTYP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_CLIENT_PERSONAL_INFO', @level2type = N'COLUMN', @level2name = N'EDUCATION_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : MRTYP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_CLIENT_PERSONAL_INFO', @level2type = N'COLUMN', @level2name = N'MARRIAGE_TYPE_CODE';

