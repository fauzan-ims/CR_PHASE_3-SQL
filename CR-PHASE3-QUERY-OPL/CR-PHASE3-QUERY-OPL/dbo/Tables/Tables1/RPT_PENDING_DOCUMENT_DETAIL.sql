CREATE TABLE [dbo].[RPT_PENDING_DOCUMENT_DETAIL] (
    [USER_ID]              NVARCHAR (50)   NULL,
    [AS_OF_DATE]           DATETIME        NULL,
    [TEAM]                 NVARCHAR (250)  NULL,
    [PIC_MKT]              NVARCHAR (250)  NULL,
    [CUSTOMER_CODE]        NVARCHAR (50)   NULL,
    [CUSTOMER_NAME]        NVARCHAR (250)  NULL,
    [KONTRAK_PELAKSANA]    NVARCHAR (50)   NULL,
    [ESTIMATE_TARGET_DATE] DATETIME        NULL,
    [AGING_DATE]           INT             NULL,
    [REMARK]               NVARCHAR (4000) NULL,
    [CRE_DATE]             DATETIME        NULL,
    [CRE_BY]               NVARCHAR (15)   NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NULL,
    [MOD_DATE]             DATETIME        NULL,
    [MOD_BY]               NVARCHAR (15)   NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NULL
);

