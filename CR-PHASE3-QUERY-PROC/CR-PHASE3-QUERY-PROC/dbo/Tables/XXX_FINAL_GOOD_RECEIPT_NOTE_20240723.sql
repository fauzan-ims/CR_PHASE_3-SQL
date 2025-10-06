CREATE TABLE [dbo].[XXX_FINAL_GOOD_RECEIPT_NOTE_20240723] (
    [CODE]           NVARCHAR (50)   NOT NULL,
    [DATE]           DATETIME        NOT NULL,
    [COMPLATE_DATE]  DATETIME        NULL,
    [STATUS]         NVARCHAR (50)   NOT NULL,
    [REFF_NO]        NVARCHAR (50)   NULL,
    [TOTAL_AMOUNT]   DECIMAL (18, 2) NULL,
    [TOTAL_ITEM]     INT             NULL,
    [RECEIVE_ITEM]   INT             NULL,
    [REMARK]         NVARCHAR (4000) NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL
);

