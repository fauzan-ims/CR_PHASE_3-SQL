CREATE TABLE [dbo].[temp_et_detail_22112023] (
    [ID]               BIGINT          IDENTITY (1, 1) NOT NULL,
    [ET_CODE]          NVARCHAR (50)   NOT NULL,
    [ASSET_NO]         NVARCHAR (50)   NOT NULL,
    [OS_RENTAL_AMOUNT] DECIMAL (18, 2) NOT NULL,
    [IS_TERMINATE]     NVARCHAR (1)    NOT NULL,
    [CRE_DATE]         DATETIME        NOT NULL,
    [CRE_BY]           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]         DATETIME        NOT NULL,
    [MOD_BY]           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NOT NULL
);

