CREATE TABLE [dbo].[XXX_MASTER_VEHICLE_MODEL_AFTER_EOM_20250731] (
    [CODE]                     NVARCHAR (50)  NOT NULL,
    [VEHICLE_MERK_CODE]        NVARCHAR (50)  NOT NULL,
    [VEHICLE_SUBCATEGORY_CODE] NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]              NVARCHAR (250) NOT NULL,
    [IS_ACTIVE]                NVARCHAR (1)   NOT NULL,
    [CRE_DATE]                 DATETIME       NOT NULL,
    [CRE_BY]                   NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                 DATETIME       NOT NULL,
    [MOD_BY]                   NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)  NOT NULL
);

