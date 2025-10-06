CREATE TABLE [dbo].[APPLICATION_ASSET_RESERVATION] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [EMPLOYEE_CODE]        NVARCHAR (50)   NOT NULL,
    [EMPLOYEE_NAME]        NVARCHAR (250)  NOT NULL,
    [RESERV_DATE]          DATETIME        NOT NULL,
    [RESERV_EXP_DATE]      DATETIME        NULL,
    [STATUS]               NVARCHAR (10)   NOT NULL,
    [CLIENT_NAME]          NVARCHAR (250)  NULL,
    [CLIENT_PHONE_AREA_NO] NVARCHAR (5)    NULL,
    [CLIENT_PHONE_NO]      NVARCHAR (15)   NULL,
    [REMARK]               NVARCHAR (4000) NOT NULL,
    [FA_CODE]              NVARCHAR (50)   NOT NULL,
    [FA_NAME]              NVARCHAR (250)  NOT NULL,
    [APPLICATION_NO]       NVARCHAR (50)   NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL
);

