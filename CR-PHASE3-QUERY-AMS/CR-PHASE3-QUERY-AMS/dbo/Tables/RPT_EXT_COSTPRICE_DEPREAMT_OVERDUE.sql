CREATE TABLE [dbo].[RPT_EXT_COSTPRICE_DEPREAMT_OVERDUE] (
    [EOM]                     DATETIME        NULL,
    [AGRMNTNO]                NVARCHAR (50)   NULL,
    [ASSETCONDITIONID]        NVARCHAR (10)   NULL,
    [ASSETMODELID]            NVARCHAR (50)   NULL,
    [COSTPRICE]               DECIMAL (18, 2) NULL,
    [DEPREAMT]                DECIMAL (18, 2) NULL,
    [PAYMENTBALANCE]          DECIMAL (18, 2) NULL,
    [CRE_BY]                  NVARCHAR (15)   NULL,
    [CRE_DATE]                DATETIME        NULL,
    [CRE_IP_ADDRESS]          NVARCHAR (15)   NULL,
    [MOD_BY]                  NVARCHAR (15)   NULL,
    [MOD_DATE]                DATETIME        NULL,
    [MOD_IP_ADDRESS]          NVARCHAR (15)   NULL,
    [fa_code]                 NVARCHAR (50)   NULL,
    [registration_class_type] NVARCHAR (50)   NULL,
    [asset_name]              NVARCHAR (4000) NULL
);

