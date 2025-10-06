CREATE TABLE [dbo].[XXX_xsp_rpt_ext_agreement_main_insert_20250809] (
    [ID]               BIGINT        IDENTITY (1, 1) NOT NULL,
    [AGREEMENT_ID]     NVARCHAR (50) NULL,
    [AS_OF]            DATETIME      NULL,
    [GO_LIVE_DATE]     DATETIME      NULL,
    [TENOR]            INT           NULL,
    [END_CONTACT_DATE] DATETIME      NULL,
    [CREATE_DATE]      DATETIME      NULL,
    [CREATE_TIME]      DATETIME      NULL,
    [CRE_DATE]         DATETIME      NULL,
    [CRE_BY]           NVARCHAR (15) NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15) NULL,
    [MOD_DATE]         DATETIME      NULL,
    [MOD_BY]           NVARCHAR (15) NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15) NULL,
    [SEQUENCE]         NVARCHAR (50) NULL
);

