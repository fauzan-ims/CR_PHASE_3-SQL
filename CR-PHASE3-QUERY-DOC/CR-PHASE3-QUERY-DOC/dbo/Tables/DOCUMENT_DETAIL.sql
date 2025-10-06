CREATE TABLE [dbo].[DOCUMENT_DETAIL] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [DOCUMENT_CODE]        NVARCHAR (50)   NOT NULL,
    [DOCUMENT_NAME]        NVARCHAR (250)  NOT NULL,
    [DOCUMENT_TYPE]        NVARCHAR (250)  NULL,
    [DOCUMENT_DATE]        DATETIME        NULL,
    [DOCUMENT_DESCRIPTION] NVARCHAR (4000) NOT NULL,
    [MODULE]               NVARCHAR (50)   NULL,
    [DOC_NO]               NVARCHAR (50)   NULL,
    [DOC_NAME]             NVARCHAR (250)  NULL,
    [FILE_NAME]            NVARCHAR (250)  NULL,
    [PATHS]                NVARCHAR (250)  NULL,
    [DOC_FILE]             VARBINARY (MAX) NULL,
    [EXPIRED_DATE]         DATETIME        NULL,
    [IS_TEMPORARY]         NVARCHAR (1)    CONSTRAINT [DF_DOCUMENT_DETAIL_IS_TEMPORARY] DEFAULT ((0)) NOT NULL,
    [IS_MANUAL]            NVARCHAR (1)    CONSTRAINT [DF_DOCUMENT_DETAIL_IS_MANUAL] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_DOCUMENT_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DOCUMENT_DETAIL_DOCUMENT_DETAIL] FOREIGN KEY ([DOCUMENT_CODE]) REFERENCES [dbo].[DOCUMENT_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCUMENT_DETAIL_DOCUMENT_CODE]
    ON [dbo].[DOCUMENT_DETAIL]([DOCUMENT_CODE] ASC, [DOCUMENT_TYPE] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCUMENT_DETAIL_DOCUMENT_TYPE_20250615]
    ON [dbo].[DOCUMENT_DETAIL]([DOCUMENT_TYPE] ASC)
    INCLUDE([DOCUMENT_CODE], [DOC_NO], [DOC_NAME]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe dokumen pada proses document main tersebut - COLLATERAL, menginformasikan bahwa dokumen tersebut merupakan dokumen collateral - LEGAL, menginformasikan bahwa dokumen tersebut merupakan dokumen legal  - INSURANCE, menginformasikan bahwa dokumen tersebut merupakan dokumen asuransi - OTHER, menginformasikan bahwa dokumen tersebut merupakan dokumen lainnya', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCUMENT_DETAIL', @level2type = N'COLUMN', @level2name = N'DOCUMENT_CODE';

