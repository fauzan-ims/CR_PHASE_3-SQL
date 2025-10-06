CREATE TABLE [dbo].[RPT_FORM_GENERAL_CHECK] (
    [USER_ID]             NVARCHAR (50)  NOT NULL,
    [REPORT_COMPANY]      NVARCHAR (250) NOT NULL,
    [REPORT_TITLE]        NVARCHAR (250) NOT NULL,
    [REPORT_IMAGE]        NVARCHAR (250) NOT NULL,
    [REPORT_ADDRESS]      NVARCHAR (250) NOT NULL,
    [FA_CODE]             NVARCHAR (50)  NULL,
    [PHONE_NO]            NVARCHAR (50)  NULL,
    [FAX_NO]              NVARCHAR (50)  NULL,
    [PLAT_NO]             NVARCHAR (50)  NULL,
    [TYPE_VEHICLE]        NVARCHAR (100) NULL,
    [YEAR]                NVARCHAR (4)   NULL,
    [COLOUR]              NVARCHAR (50)  NULL,
    [CHASSIS_NO]          NVARCHAR (50)  NULL,
    [ENGINE_NO]           NVARCHAR (50)  NULL,
    [STNK_DATE]           DATETIME       NULL,
    [IMPLEMENTATION_DATE] DATETIME       NULL,
    [KM]                  INT            NULL,
    [FUEL]                NVARCHAR (50)  NULL,
    [SURVEYOR]            NVARCHAR (50)  NULL,
    [PLACE]               NVARCHAR (50)  NULL,
    [CRE_DATE]            DATETIME       NULL
);

