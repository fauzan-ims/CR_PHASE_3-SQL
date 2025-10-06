CREATE TABLE [dbo].[FAKTUR_NO_REPLACEMENT_DETAIL_UPLOAD_VALIDASI_1] (
    [ID]                         BIGINT          IDENTITY (1, 1) NOT NULL,
    [ID_UPLOAD_DATA]             BIGINT          NOT NULL,
    [FAKTUR_NO_REPLACEMENT_CODE] NVARCHAR (50)   NOT NULL,
    [USER_ID]                    NVARCHAR (50)   NOT NULL,
    [UPLOAD_DATE]                DATETIME        NOT NULL,
    [VALIDASI]                   NVARCHAR (4000) NULL,
    [CRE_DATE]                   DATETIME        NOT NULL,
    [CRE_BY]                     NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                   DATETIME        NOT NULL,
    [MOD_BY]                     NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_FAKTUR_NO_REPLACEMENT_DETAIL_UPLOAD_VALIDASI_1] PRIMARY KEY CLUSTERED ([ID] ASC)
);

