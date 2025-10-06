CREATE TABLE [dbo].[XXX_DUE_DATE_CHANGE_DETAIL_20250502] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [DUE_DATE_CHANGE_CODE] NVARCHAR (50)   NOT NULL,
    [ASSET_NO]             NVARCHAR (50)   NOT NULL,
    [OS_RENTAL_AMOUNT]     DECIMAL (18, 2) NOT NULL,
    [OLD_DUE_DATE_DAY]     DATETIME        NULL,
    [NEW_DUE_DATE_DAY]     DATETIME        NULL,
    [AT_INSTALLMENT_NO]    INT             NULL,
    [IS_CHANGE]            NVARCHAR (1)    NOT NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [is_every_eom]         NVARCHAR (1)    NULL
);

