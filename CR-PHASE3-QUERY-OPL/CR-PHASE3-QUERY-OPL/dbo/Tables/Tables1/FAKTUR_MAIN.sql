CREATE TABLE [dbo].[FAKTUR_MAIN] (
    [FAKTUR_NO]         NVARCHAR (50)  NOT NULL,
    [YEAR]              NVARCHAR (4)   NOT NULL,
    [STATUS]            NVARCHAR (10)  NOT NULL,
    [REGISTRATION_CODE] NVARCHAR (50)  NULL,
    [INVOICE_NO]        NVARCHAR (250) NULL,
    [CRE_DATE]          DATETIME       NOT NULL,
    [CRE_BY]            NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    [MOD_DATE]          DATETIME       NOT NULL,
    [MOD_BY]            NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_FAKTUR_MAIN] PRIMARY KEY CLUSTERED ([FAKTUR_NO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NEW, USED, CANCEL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FAKTUR_MAIN', @level2type = N'COLUMN', @level2name = N'STATUS';

