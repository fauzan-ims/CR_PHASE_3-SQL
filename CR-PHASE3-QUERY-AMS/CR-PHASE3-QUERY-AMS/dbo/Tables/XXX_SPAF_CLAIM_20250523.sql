CREATE TABLE [dbo].[XXX_SPAF_CLAIM_20250523] (
    [CODE]               NVARCHAR (50)   NOT NULL,
    [DATE]               DATETIME        NOT NULL,
    [STATUS]             NVARCHAR (50)   NOT NULL,
    [CLAIM_AMOUNT]       DECIMAL (18, 2) NULL,
    [PPN_AMOUNT]         DECIMAL (18, 2) NULL,
    [PPH_AMOUNT]         DECIMAL (18, 2) NULL,
    [TOTAL_CLAIM_AMOUNT] DECIMAL (18, 2) NOT NULL,
    [CLAIM_TYPE]         NVARCHAR (25)   NULL,
    [RECEIPT_NO]         NVARCHAR (50)   NULL,
    [REMARK]             NVARCHAR (4000) NOT NULL,
    [REFF_CLAIM_REQ_NO]  NVARCHAR (50)   NULL,
    [CRE_DATE]           DATETIME        NOT NULL,
    [CRE_BY]             NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    [MOD_DATE]           DATETIME        NOT NULL,
    [MOD_BY]             NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    [FAKTUR_NO]          NVARCHAR (50)   NULL,
    [FAKTUR_DATE]        DATETIME        NULL
);

