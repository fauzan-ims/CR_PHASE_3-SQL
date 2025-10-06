CREATE TABLE [dbo].[XXX_MAIN_CONTRACT_TC_20250312] (
    [ID]               BIGINT          IDENTITY (1, 1) NOT NULL,
    [MAIN_CONTRACT_NO] NVARCHAR (50)   NOT NULL,
    [DESCRIPTION]      NVARCHAR (4000) NULL,
    [CRE_DATE]         DATETIME        NULL,
    [CRE_BY]           NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NULL,
    [MOD_DATE]         DATETIME        NULL,
    [MOD_BY]           NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NULL
);

