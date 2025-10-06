CREATE TABLE [dbo].[CLIENT_BLACKLIST_TRANSACTION] (
    [CODE]                NVARCHAR (50)   NOT NULL,
    [TRANSACTION_STATUS]  NVARCHAR (10)   NOT NULL,
    [TRANSACTION_TYPE]    NVARCHAR (10)   NOT NULL,
    [TRANSACTION_DATE]    DATETIME        NOT NULL,
    [TRANSACTION_REMARKS] NVARCHAR (4000) NOT NULL,
    [REGISTER_SOURCE]     NVARCHAR (250)  NOT NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_CLIENT_NEGATIVE_AND_WARNING_TRANSACTION] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'REGISTER, RELEASE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_BLACKLIST_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_BLACKLIST_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_DATE';

