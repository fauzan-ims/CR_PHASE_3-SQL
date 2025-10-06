CREATE TABLE [dbo].[GOOD_RECEIPT_NOTE_DETAIL_DOC] (
    [ID]                          BIGINT         IDENTITY (1, 1) NOT NULL,
    [GOOD_RECEIPT_NOTE_DETAIL_ID] INT            NOT NULL,
    [DOCUMENT_CODE]               NVARCHAR (50)  NULL,
    [FILE_NAME]                   NVARCHAR (250) NULL,
    [FILE_PATH]                   NVARCHAR (250) NULL,
    [EXPIRED_DATE]                DATETIME       NULL,
    [CRE_DATE]                    DATETIME       NOT NULL,
    [CRE_BY]                      NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                    DATETIME       NOT NULL,
    [MOD_BY]                      NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_GOOD_RECEIPT_NOTE_DETAIL_DOC] PRIMARY KEY CLUSTERED ([ID] ASC)
);

