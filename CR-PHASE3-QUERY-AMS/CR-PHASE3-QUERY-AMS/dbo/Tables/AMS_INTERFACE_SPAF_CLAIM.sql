CREATE TABLE [dbo].[AMS_INTERFACE_SPAF_CLAIM] (
    [ID]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [DATE]               DATETIME        NOT NULL,
    [STATUS]             NVARCHAR (50)   NOT NULL,
    [FA_CODE]            NVARCHAR (50)   NULL,
    [CLAIM_AMOUNT]       DECIMAL (18, 2) NULL,
    [PPN_AMOUNT]         DECIMAL (18, 2) NULL,
    [PPH_AMOUNT]         DECIMAL (18, 2) NULL,
    [TOTAL_CLAIM_AMOUNT] DECIMAL (18, 2) NULL,
    [CLAIM_TYPE]         NVARCHAR (250)  NULL,
    [CLAIM_NO]           NVARCHAR (50)   NULL,
    [RECEIPT_NO]         NVARCHAR (50)   NULL,
    [REMARK]             NVARCHAR (4000) NOT NULL,
    [JOB_STATUS]         NVARCHAR (15)   NULL,
    [CRE_DATE]           DATETIME        NOT NULL,
    [CRE_BY]             NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    [MOD_DATE]           DATETIME        NOT NULL,
    [MOD_BY]             NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_AMS_INTERFACE_SPAF_CLAIM] PRIMARY KEY CLUSTERED ([ID] ASC)
);

