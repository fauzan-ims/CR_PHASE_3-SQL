CREATE TABLE [dbo].[OPL_INTERFACE_CLIENT_MAIN] (
    [ID]                       BIGINT         IDENTITY (1, 1) NOT NULL,
    [CODE]                     NVARCHAR (50)  NOT NULL,
    [CLIENT_TYPE]              NVARCHAR (10)  NOT NULL,
    [CLIENT_NO]                NVARCHAR (50)  NOT NULL,
    [CLIENT_NAME]              NVARCHAR (250) NOT NULL,
    [CLIENT_GROUP_CODE]        NVARCHAR (50)  NULL,
    [CLIENT_GROUP_NAME]        NVARCHAR (250) NULL,
    [IS_VALIDATE]              NVARCHAR (1)   NOT NULL,
    [IS_RED_FLAG]              NVARCHAR (1)   CONSTRAINT [DF_OPL_INTERFACE_CLIENT_MAIN_IS_RED_FLAG] DEFAULT ((0)) NOT NULL,
    [WATCHLIST_STATUS]         NVARCHAR (10)  CONSTRAINT [DF_OPL_INTERFACE_CLIENT_MAIN_WATCHLIST_STATUS] DEFAULT ('') NOT NULL,
    [STATUS_SLIK_CHECKING]     NVARCHAR (10)  NOT NULL,
    [STATUS_DUKCAPIL_CHECKING] NVARCHAR (10)  NOT NULL,
    [CRE_DATE]                 DATETIME       NOT NULL,
    [CRE_BY]                   NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                 DATETIME       NOT NULL,
    [MOD_BY]                   NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_OPL_INTERFACE_CLIENT_MAIN] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PERSONAL, CORPORATE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_CLIENT_MAIN', @level2type = N'COLUMN', @level2name = N'CLIENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PERSONAL, CORPORATE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_CLIENT_MAIN', @level2type = N'COLUMN', @level2name = N'CLIENT_NO';

