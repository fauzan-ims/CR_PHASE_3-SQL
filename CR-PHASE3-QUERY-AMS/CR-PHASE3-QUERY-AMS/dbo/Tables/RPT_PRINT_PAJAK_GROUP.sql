CREATE TABLE [dbo].[RPT_PRINT_PAJAK_GROUP] (
    [USER_ID]        NVARCHAR (50) NOT NULL,
    [SALE_ID]        INT           NOT NULL,
    [CRE_DATE]       DATETIME      NULL,
    [CRE_BY]         NVARCHAR (50) NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15) NULL,
    [MOD_DATE]       DATETIME      NULL,
    [MOD_BY]         NVARCHAR (50) NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15) NULL
);

