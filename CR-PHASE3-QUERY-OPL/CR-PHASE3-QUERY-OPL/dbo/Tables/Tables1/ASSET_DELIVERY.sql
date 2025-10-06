CREATE TABLE [dbo].[ASSET_DELIVERY] (
    [CODE]                NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]         NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]         NVARCHAR (250)  NOT NULL,
    [STATUS]              NVARCHAR (10)   NOT NULL,
    [DATE]                DATETIME        NOT NULL,
    [REMARK]              NVARCHAR (4000) NOT NULL,
    [DELIVER_TO_NAME]     NVARCHAR (250)  NOT NULL,
    [DELIVER_TO_AREA_NO]  NVARCHAR (4)    NOT NULL,
    [DELIVER_TO_PHONE_NO] NVARCHAR (15)   NOT NULL,
    [DELIVER_TO_ADDRESS]  NVARCHAR (4000) NOT NULL,
    [DELIVER_FROM]        NVARCHAR (20)   NOT NULL,
    [DELIVER_BY]          NVARCHAR (250)  NULL,
    [DELIVER_PIC]         NVARCHAR (250)  NULL,
    [EMPLOYEE_CODE]       NVARCHAR (50)   NULL,
    [EMPLOYEE_NAME]       NVARCHAR (250)  NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_ASSET_DELIVERY] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Supplier, Internal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ASSET_DELIVERY', @level2type = N'COLUMN', @level2name = N'DELIVER_FROM';

