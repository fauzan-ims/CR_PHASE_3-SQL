CREATE TABLE [dbo].[OPL_INTERFACE_APPLICATION_MAIN] (
    [ID]                    BIGINT         IDENTITY (1, 1) NOT NULL,
    [AGREEMENT_NO]          NVARCHAR (50)  NOT NULL,
    [AGREEMENT_EXTERNAL_NO] NVARCHAR (50)  NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)  NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250) NOT NULL,
    [AGREEMENT_DATE]        DATETIME       NOT NULL,
    [AGREEMENT_STATUS]      NVARCHAR (10)  NOT NULL,
    [AGREEMENT_SUB_STATUS]  NVARCHAR (20)  CONSTRAINT [DF_OPL_INTERFACE_APPLICATION_MAIN_AGREEMENT_SUB_STATUS] DEFAULT ('') NULL,
    [TERMINATION_DATE]      DATETIME       NULL,
    [TERMINATION_STATUS]    NVARCHAR (20)  NULL,
    [CLIENT_NO]             NVARCHAR (50)  NULL,
    [CLIENT_NAME]           NVARCHAR (250) NOT NULL,
    [CRE_DATE]              DATETIME       NOT NULL,
    [CRE_BY]                NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)  NOT NULL,
    [MOD_DATE]              DATETIME       NOT NULL,
    [MOD_BY]                NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_OPL_INTERFACE_APPLICATION_MAIN] PRIMARY KEY CLUSTERED ([AGREEMENT_NO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada data agreement main tersebut - GO LIVE, menginformasikan bahwa kontrak pembiayaan tersebut sedang berstatus Go Live - TERMINATE, menginformasikan bahwa data kontrak pembiayaan tersebut sudah dilakukan proses terminate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPL_INTERFACE_APPLICATION_MAIN', @level2type = N'COLUMN', @level2name = N'AGREEMENT_SUB_STATUS';

