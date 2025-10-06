CREATE TABLE [dbo].[RPT_EXT_ASSET_SELLING] (
    [ID]                      BIGINT          IDENTITY (1, 1) NOT NULL,
    [EOM]                     DATETIME        NULL,
    [ASSETNO]                 NVARCHAR (50)   NULL,
    [AMT]                     DECIMAL (18, 2) NULL,
    [ASSETCONDITIONID]        NVARCHAR (50)   NULL,
    [ASSETTYPEID]             NVARCHAR (50)   NULL,
    [ASSETBRANDID]            NVARCHAR (50)   NULL,
    [ASSETBRANDTYPEID]        NVARCHAR (50)   NULL,
    [ASSETBRANDTYPENAME]      NVARCHAR (250)  NULL,
    [ASSETMODELID]            NVARCHAR (50)   NULL,
    [CRE_DATE]                DATETIME        NULL,
    [CRE_BY]                  NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]          NVARCHAR (15)   NULL,
    [MOD_DATE]                DATETIME        NULL,
    [MOD_BY]                  NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]          NVARCHAR (15)   NULL,
    [fa_code]                 NVARCHAR (50)   NULL,
    [registration_class_type] NVARCHAR (50)   NULL,
    [asset_name]              NVARCHAR (4000) NULL,
    CONSTRAINT [PK__RPT_EXT___3214EC27464374E7] PRIMARY KEY CLUSTERED ([ID] ASC)
);

