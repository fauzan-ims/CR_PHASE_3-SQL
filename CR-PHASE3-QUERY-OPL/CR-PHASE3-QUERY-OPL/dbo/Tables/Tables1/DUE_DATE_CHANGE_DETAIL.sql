CREATE TABLE [dbo].[DUE_DATE_CHANGE_DETAIL] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [DUE_DATE_CHANGE_CODE]   NVARCHAR (50)   NOT NULL,
    [ASSET_NO]               NVARCHAR (50)   NOT NULL,
    [OS_RENTAL_AMOUNT]       DECIMAL (18, 2) NOT NULL,
    [OLD_DUE_DATE_DAY]       DATETIME        CONSTRAINT [DF_DUE_DATE_CHANGE_DETAIL_OLD_DUE_DATE_DAY] DEFAULT ((0)) NULL,
    [NEW_DUE_DATE_DAY]       DATETIME        CONSTRAINT [DF_DUE_DATE_CHANGE_DETAIL_NEW_DUE_DATE_DAY] DEFAULT ((0)) NULL,
    [AT_INSTALLMENT_NO]      INT             CONSTRAINT [DF_DUE_DATE_CHANGE_DETAIL_AT_INSTALLMENT_NO] DEFAULT ((0)) NULL,
    [IS_CHANGE]              NVARCHAR (1)    NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [is_every_eom]           NVARCHAR (1)    NULL,
    [OLD_BILLING_DATE]       DATETIME        NULL,
    [NEW_BILLING_DATE]       DATETIME        NULL,
    [IS_CHANGE_BILLING_DATE] NVARCHAR (1)    NULL,
    [BILLING_MODE]           NVARCHAR (50)   NULL,
    [PRORATE]                NVARCHAR (15)   NULL,
    [DATE_FOR_BILLING]       INT             NULL,
    [is_change_billing]      NVARCHAR (1)    NULL,
    [billing_mode_date]      INT             NULL,
    CONSTRAINT [PK_DUE_DATE_CHANGE_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode ET pada data ET detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_DETAIL', @level2type = N'COLUMN', @level2name = N'DUE_DATE_CHANGE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor asset pada data ET detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_DETAIL', @level2type = N'COLUMN', @level2name = N'ASSET_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal jatuh tempo sebelum dilakukan proses perubahan ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_DETAIL', @level2type = N'COLUMN', @level2name = N'OLD_DUE_DATE_DAY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal jatuh tempo setelah dilakukan proses perubahan ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_DETAIL', @level2type = N'COLUMN', @level2name = N'NEW_DUE_DATE_DAY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor angsuran pada proses perubahan tanggal jatuh tempo tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_DETAIL', @level2type = N'COLUMN', @level2name = N'AT_INSTALLMENT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data tersebut dilakukan proses terminate?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DUE_DATE_CHANGE_DETAIL', @level2type = N'COLUMN', @level2name = N'IS_CHANGE';

