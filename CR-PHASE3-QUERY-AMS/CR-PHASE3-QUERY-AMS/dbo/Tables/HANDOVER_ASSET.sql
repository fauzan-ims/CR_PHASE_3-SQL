CREATE TABLE [dbo].[HANDOVER_ASSET] (
    [CODE]                     NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]              NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]              NVARCHAR (250)  NOT NULL,
    [STATUS]                   NVARCHAR (10)   NOT NULL,
    [TRANSACTION_DATE]         DATETIME        NOT NULL,
    [HANDOVER_DATE]            DATETIME        NULL,
    [TYPE]                     NVARCHAR (20)   NOT NULL,
    [REMARK]                   NVARCHAR (4000) NOT NULL,
    [FA_CODE]                  NVARCHAR (50)   NOT NULL,
    [HANDOVER_FROM]            NVARCHAR (250)  NULL,
    [HANDOVER_TO]              NVARCHAR (250)  NULL,
    [HANDOVER_ADDRESS]         NVARCHAR (4000) NULL,
    [HANDOVER_PHONE_AREA]      NVARCHAR (5)    NULL,
    [HANDOVER_PHONE_NO]        NVARCHAR (15)   NULL,
    [UNIT_CONDITION]           NVARCHAR (4000) NULL,
    [REFF_CODE]                NVARCHAR (50)   NULL,
    [REFF_NAME]                NVARCHAR (250)  NULL,
    [PROCESS_STATUS]           NVARCHAR (50)   NULL,
    [PLAN_DATE]                DATETIME        NULL,
    [KM]                       INT             NULL,
    [GATE_PASS_CODE]           NVARCHAR (50)   NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [COURIER]                  NVARCHAR (50)   NULL,
    [PIC_HANDOVER_NAME]        NVARCHAR (250)  NULL,
    [PIC_HANDOVER_ADDRESS]     NVARCHAR (4000) NULL,
    [PIC_HANDOVER_PHONE_AREA]  NVARCHAR (5)    NULL,
    [PIC_HANDOVER_PHONE_NO]    NVARCHAR (15)   NULL,
    [PIC_RECIPIENT_NAME]       NVARCHAR (250)  NULL,
    [PIC_RECIPIENT_PHONE_AREA] NVARCHAR (5)    NULL,
    [PIC_RECIPIENT_PHONE_NO]   NVARCHAR (15)   NULL,
    CONSTRAINT [PK_HANDOVER_ASSET] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_HANDOVER_ASSET_TRANSACTION_DATE_TYPE_20250615]
    ON [dbo].[HANDOVER_ASSET]([TRANSACTION_DATE] ASC, [TYPE] ASC)
    INCLUDE([BRANCH_CODE], [STATUS], [HANDOVER_DATE], [FA_CODE], [HANDOVER_ADDRESS], [HANDOVER_PHONE_AREA], [HANDOVER_PHONE_NO], [UNIT_CONDITION]);


GO
CREATE NONCLUSTERED INDEX [IDX_HANDOVER_ASSET_TYPE_20250615]
    ON [dbo].[HANDOVER_ASSET]([TYPE] ASC)
    INCLUDE([HANDOVER_DATE]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DELIVERY, RETURN, REPLACE IN, REPLACE OUT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HANDOVER_ASSET', @level2type = N'COLUMN', @level2name = N'TYPE';

