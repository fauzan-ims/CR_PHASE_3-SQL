CREATE TABLE [dbo].[XXX_MATURITY_DETAIL_20241105] (
    [ID]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [MATURITY_CODE]      NVARCHAR (50)   NOT NULL,
    [ASSET_NO]           NVARCHAR (50)   NOT NULL,
    [RESULT]             NVARCHAR (10)   NOT NULL,
    [ADDITIONAL_PERIODE] INT             NOT NULL,
    [REMARK]             NVARCHAR (4000) NOT NULL,
    [PICKUP_DATE]        DATETIME        NULL,
    [CRE_DATE]           DATETIME        NOT NULL,
    [CRE_BY]             NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    [MOD_DATE]           DATETIME        NOT NULL,
    [MOD_BY]             NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)   NOT NULL
);

