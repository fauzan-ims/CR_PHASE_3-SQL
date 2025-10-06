CREATE TABLE [dbo].[BILLING_GENERATE] (
    [CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]    NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]    NVARCHAR (250)  NOT NULL,
    [DATE]           DATETIME        NOT NULL,
    [STATUS]         NVARCHAR (10)   NOT NULL,
    [REMARK]         NVARCHAR (4000) NOT NULL,
    [CLIENT_NO]      NVARCHAR (50)   NULL,
    [CLIENT_NAME]    NVARCHAR (250)  NULL,
    [AGREEMENT_NO]   NVARCHAR (50)   NULL,
    [ASSET_NO]       NVARCHAR (50)   NULL,
    [AS_OFF_DATE]    DATETIME        NOT NULL,
    [IS_EOD]         NVARCHAR (1)    NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_BILLING_GENERATE] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BILLING_GENERATE', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BILLING_GENERATE', @level2type = N'COLUMN', @level2name = N'ASSET_NO';

