CREATE TABLE [dbo].[DOC_INTERFACE_COLLATERAL_SWITCH_REPLACED] (
    [ID]                               BIGINT          IDENTITY (1, 1) NOT NULL,
    [REPLACED_COLLATERAL_NO]           NVARCHAR (50)   NOT NULL,
    [INTERFACE_COLLATERAL_SWITCH_CODE] NVARCHAR (50)   NOT NULL,
    [COLLATERALL_NO]                   NVARCHAR (50)   NOT NULL,
    [COLLATERAL_TYPE]                  NVARCHAR (10)   NOT NULL,
    [COLLATERAL_NAME]                  NVARCHAR (250)  NOT NULL,
    [COLLATERAL_DESCRIPTION]           NVARCHAR (250)  NOT NULL,
    [COLLATERAL_CONDITION]             NVARCHAR (5)    NOT NULL,
    [COLLATERAL_VALUE_AMOUNT]          DECIMAL (18, 2) CONSTRAINT [DF_DOC_INTERFACE_COLLATERAL_SWITCH_REPLACED_COLLATERAL_VALUE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [MARKET_VALUE_AMOUNT]              DECIMAL (18, 2) CONSTRAINT [DF_DOC_INTERFACE_COLLATERAL_SWITCH_REPLACED_MARKET_VALUE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [DOC_COLLATERAL_NO]                NVARCHAR (50)   NOT NULL,
    [COLLATERAL_YEAR]                  NVARCHAR (4)    NOT NULL,
    [JOB_STATUS]                       NVARCHAR (20)   CONSTRAINT [DF_DOC_INTERFACE_COLLATERAL_SWITCH_REPLACED_JOB_STATUS] DEFAULT (N'HOLD') NULL,
    [FAILED_REMARK]                    NVARCHAR (4000) NULL,
    [CRE_DATE]                         DATETIME        NOT NULL,
    [CRE_BY]                           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                         DATETIME        NOT NULL,
    [MOD_BY]                           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                   NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_DOC_INTERFACE_COLLATERAL_SWITCH_REPLACED] PRIMARY KEY CLUSTERED ([REPLACED_COLLATERAL_NO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor dokumen collateral pada data agremeent collateral tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_COLLATERAL_SWITCH_REPLACED', @level2type = N'COLUMN', @level2name = N'DOC_COLLATERAL_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tahun collateral pada data agremeent collateral tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOC_INTERFACE_COLLATERAL_SWITCH_REPLACED', @level2type = N'COLUMN', @level2name = N'COLLATERAL_YEAR';

