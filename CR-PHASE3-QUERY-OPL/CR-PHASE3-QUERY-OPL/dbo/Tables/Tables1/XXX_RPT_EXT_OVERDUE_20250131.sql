CREATE TABLE [dbo].[XXX_RPT_EXT_OVERDUE_20250131] (
    [ID]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [EOM]                DATETIME        NULL,
    [AGRMNTNO]           NVARCHAR (50)   NULL,
    [CURRENCY]           NVARCHAR (3)    NULL,
    [PAYMENTBALANCE]     DECIMAL (18, 2) NULL,
    [ASSETCONDITIONID]   NVARCHAR (50)   NULL,
    [ASSETTYPEID]        NVARCHAR (50)   NULL,
    [ASSETBRANDID]       NVARCHAR (50)   NULL,
    [ASSETBRANDTYPEID]   NVARCHAR (50)   NULL,
    [ASSETBRANDTYPENAME] NVARCHAR (250)  NULL,
    [ASSETMODELID]       NVARCHAR (50)   NULL,
    [CRE_DATE]           DATETIME        NULL,
    [CRE_BY]             NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)   NULL,
    [MOD_DATE]           DATETIME        NULL,
    [MOD_BY]             NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)   NULL
);

