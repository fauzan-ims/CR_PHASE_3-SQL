CREATE TABLE [dbo].[XXX_MAIN_CONTRACT_MAIN_20241011] (
    [ID]                      BIGINT          IDENTITY (1, 1) NOT NULL,
    [MAIN_CONTRACT_NO]        NVARCHAR (50)   NOT NULL,
    [MAIN_CONTRACT_FILE_NAME] NVARCHAR (250)  NOT NULL,
    [MAIN_CONTRACT_FILE_PATH] NVARCHAR (250)  NOT NULL,
    [CLIENT_NO]               NVARCHAR (50)   NULL,
    [REMARKS]                 NVARCHAR (4000) NOT NULL,
    [CRE_DATE]                DATETIME        NOT NULL,
    [CRE_BY]                  NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]          NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                DATETIME        NOT NULL,
    [MOD_BY]                  NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]          NVARCHAR (15)   NOT NULL,
    [IS_STANDART]             NVARCHAR (1)    NULL,
    [MAIN_CONTRACT_DATE]      DATETIME        NULL
);

