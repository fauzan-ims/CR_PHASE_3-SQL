CREATE TABLE [dbo].[UPLOAD_ERROR_LOG] (
    [ID]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [TABEL_NAME]          NVARCHAR (250)  NOT NULL,
    [PRIMARY_COLUMN_NAME] NVARCHAR (250)  NOT NULL,
    [COLUMN_NAME]         NVARCHAR (250)  NOT NULL,
    [ERROR]               NVARCHAR (4000) NOT NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL
);

