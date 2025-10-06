CREATE TABLE [dbo].[HANDOVER_REQUEST] (
    [CODE]                  NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]           NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]           NVARCHAR (250)  NOT NULL,
    [TYPE]                  NVARCHAR (50)   NOT NULL,
    [STATUS]                NVARCHAR (15)   NOT NULL,
    [DATE]                  DATETIME        NOT NULL,
    [HANDOVER_FROM]         NVARCHAR (250)  NOT NULL,
    [HANDOVER_TO]           NVARCHAR (250)  NOT NULL,
    [HANDOVER_ADDRESS]      NVARCHAR (4000) NULL,
    [HANDOVER_PHONE_AREA]   NVARCHAR (5)    NULL,
    [HANDOVER_PHONE_NO]     NVARCHAR (20)   NULL,
    [ETA_DATE]              DATETIME        NULL,
    [FA_CODE]               NVARCHAR (50)   NOT NULL,
    [REMARK]                NVARCHAR (4000) NOT NULL,
    [REFF_CODE]             NVARCHAR (50)   NULL,
    [REFF_NAME]             NVARCHAR (50)   NULL,
    [HANDOVER_CODE]         NVARCHAR (50)   NULL,
    [AGREEMENT_NO]          NVARCHAR (50)   NULL,
    [AGREEMENT_EXTERNAL_NO] NVARCHAR (50)   NULL,
    [ASSET_NO]              NVARCHAR (50)   NULL,
    [CLIENT_NO]             NVARCHAR (50)   NULL,
    [CLIENT_NAME]           NVARCHAR (250)  NULL,
    [BBN]                   NVARCHAR (250)  NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_HANDOVER_REQUEST] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_HANDOVER_REQUEST_HANDOVER_CODE_20250615]
    ON [dbo].[HANDOVER_REQUEST]([HANDOVER_CODE] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DELIVERY, RETURN, REPLACE IN, REPLACE OUT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HANDOVER_REQUEST', @level2type = N'COLUMN', @level2name = N'TYPE';

