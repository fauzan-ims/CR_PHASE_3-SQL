CREATE TABLE [dbo].[GOOD_RECEIPT_NOTE_DETAIL_CHECKLIST] (
    [ID]                                      BIGINT          IDENTITY (1, 1) NOT NULL,
    [GOOD_RECEIPT_NOTE_DETAIL_ID]             INT             NOT NULL,
    [GOOD_RECEIPT_NOTE_DETAIL_OBJECT_INFO_ID] INT             NULL,
    [CHECKLIST_CODE]                          NVARCHAR (250)  NULL,
    [CHECKLIST_NAME]                          NVARCHAR (250)  NULL,
    [CHECKLIST_STATUS]                        NVARCHAR (10)   NULL,
    [CHECKLIST_REMARK]                        NVARCHAR (4000) NULL,
    [CRE_DATE]                                DATETIME        NOT NULL,
    [CRE_BY]                                  NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                          NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                                DATETIME        NOT NULL,
    [MOD_BY]                                  NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                          NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_GOOD_RECEIPT_NOTE_DETAIL_CHECKLIST] PRIMARY KEY CLUSTERED ([ID] ASC)
);

