CREATE TABLE [dbo].[XXX_AGREEMENT_ASSET_VEHICLE_07112023] (
    [ASSET_NO]                 NVARCHAR (50)   NOT NULL,
    [VEHICLE_CATEGORY_CODE]    NVARCHAR (50)   NULL,
    [VEHICLE_SUBCATEGORY_CODE] NVARCHAR (50)   NULL,
    [VEHICLE_MERK_CODE]        NVARCHAR (50)   NULL,
    [VEHICLE_MODEL_CODE]       NVARCHAR (50)   NULL,
    [VEHICLE_TYPE_CODE]        NVARCHAR (50)   NULL,
    [VEHICLE_UNIT_CODE]        NVARCHAR (50)   NULL,
    [COLOUR]                   NVARCHAR (250)  NULL,
    [TRANSMISI]                NVARCHAR (250)  NULL,
    [REMARKS]                  NVARCHAR (4000) NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL
);

