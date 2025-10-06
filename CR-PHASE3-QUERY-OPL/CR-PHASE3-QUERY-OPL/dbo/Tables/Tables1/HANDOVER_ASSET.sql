CREATE TABLE [dbo].[HANDOVER_ASSET] (
    [CODE]                   NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]            NVARCHAR (250)  NOT NULL,
    [STATUS]                 NVARCHAR (10)   NOT NULL,
    [TRANSACTION_DATE]       DATETIME        NOT NULL,
    [HANDOVER_DATE]          DATETIME        NOT NULL,
    [TYPE]                   NVARCHAR (10)   NOT NULL,
    [FIRST_INSTALLMENT_DATE] DATETIME        NULL,
    [REMARK]                 NVARCHAR (4000) NOT NULL,
    [AGREEMENT_NO]           NVARCHAR (50)   NOT NULL,
    [ASSET_NO]               NVARCHAR (50)   NOT NULL,
    [HANDOVER_FROM]          NVARCHAR (250)  NULL,
    [HANDOVER_TO]            NVARCHAR (250)  NULL,
    [UNIT_CONDITION]         NVARCHAR (4000) NULL,
    [REFF_CODE]              NVARCHAR (50)   NULL,
    [REFF_NAME]              NVARCHAR (250)  NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_HANDOVER_ASSET] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DELIVERY, RETURN, REPLACE IN, REPLACE OUT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HANDOVER_ASSET', @level2type = N'COLUMN', @level2name = N'TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HANDOVER_ASSET', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HANDOVER_ASSET', @level2type = N'COLUMN', @level2name = N'ASSET_NO';

