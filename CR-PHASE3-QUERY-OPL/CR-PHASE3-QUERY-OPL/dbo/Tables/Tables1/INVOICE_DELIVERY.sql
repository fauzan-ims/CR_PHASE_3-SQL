CREATE TABLE [dbo].[INVOICE_DELIVERY] (
    [CODE]                   NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]            NVARCHAR (250)  NOT NULL,
    [STATUS]                 NVARCHAR (10)   NOT NULL,
    [DATE]                   DATETIME        NOT NULL,
    [METHOD]                 NVARCHAR (10)   NOT NULL,
    [EMPLOYEE_CODE]          NVARCHAR (50)   NULL,
    [EMPLOYEE_NAME]          NVARCHAR (250)  NULL,
    [EXTERNAL_PIC_NAME]      NVARCHAR (250)  NULL,
    [EMAIL]                  NVARCHAR (250)  NOT NULL,
    [REMARK]                 NVARCHAR (4000) NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [DELIVERY_RESULT]        NVARCHAR (10)   NULL,
    [DELIVERY_RECEIVED_DATE] DATETIME        NULL,
    [DELIVERY_RECEIVED_BY]   NVARCHAR (250)  NULL,
    [DELIVERY_DOC_REFF_NO]   NVARCHAR (50)   NULL,
    [DELIVERY_REJECT_DATE]   DATETIME        NULL,
    [DELIVERY_REASON_CODE]   NVARCHAR (50)   NULL,
    [CLIENT_NO]              NVARCHAR (50)   NULL,
    [CLIENT_ADDRESS]         NVARCHAR (4000) NULL,
    [PROCEED_DATE]           DATETIME        NULL,
    CONSTRAINT [PK_INVOICE_DELIVERY] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'INTERNAL, EXTERNAL, EMAIL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE_DELIVERY', @level2type = N'COLUMN', @level2name = N'METHOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PIC Pengiriman. amail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVOICE_DELIVERY', @level2type = N'COLUMN', @level2name = N'EMAIL';

