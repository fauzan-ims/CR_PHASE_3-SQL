CREATE TABLE [dbo].[MASTER_OTHER_BUDGET] (
    [CODE]                   NVARCHAR (50)   NOT NULL,
    [DESCRIPTION]            NVARCHAR (4000) NOT NULL,
    [CLASS_CODE]             NVARCHAR (50)   NOT NULL,
    [CLASS_DESCRIPTION]      NVARCHAR (4000) NOT NULL,
    [EXP_DATE]               DATETIME        NOT NULL,
    [IS_SUBJECT_TO_PURCHASE] NVARCHAR (1)    NOT NULL,
    [IS_ACTIVE]              NVARCHAR (1)    NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_MASTER_OTHER_BUDGET] PRIMARY KEY CLUSTERED ([CODE] ASC)
);

