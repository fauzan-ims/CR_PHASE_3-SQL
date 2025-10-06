CREATE TABLE [dbo].[cd_asset_maintenance_schedule_backup_phase3] (
    [ID]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [ASSET_CODE]         NVARCHAR (50)  NOT NULL,
    [MAINTENANCE_NO]     NVARCHAR (50)  NULL,
    [MAINTENANCE_DATE]   DATETIME       NULL,
    [MAINTENANCE_STATUS] NVARCHAR (20)  NULL,
    [LAST_STATUS_DATE]   DATETIME       NULL,
    [REFF_TRX_NO]        NVARCHAR (50)  NULL,
    [MILES]              INT            NULL,
    [MONTH]              INT            NULL,
    [HOUR]               INT            NULL,
    [SERVICE_CODE]       NVARCHAR (50)  NULL,
    [SERVICE_NAME]       NVARCHAR (250) NULL,
    [SERVICE_TYPE]       NVARCHAR (50)  NULL,
    [SERVICE_DATE]       DATETIME       NULL,
    [CRE_BY]             NVARCHAR (15)  NULL,
    [CRE_DATE]           DATETIME       NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)  NULL,
    [MOD_BY]             NVARCHAR (15)  NULL,
    [MOD_DATE]           DATETIME       NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)  NULL
);

