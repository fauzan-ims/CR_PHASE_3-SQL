CREATE TABLE [dbo].[XXX_ORDER_MAIN_06112023] (
    [CODE]                NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [BRANCH_CODE]         NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]         NVARCHAR (250)  NOT NULL,
    [ORDER_NO]            NVARCHAR (50)   NOT NULL,
    [ORDER_DATE]          DATETIME        NOT NULL,
    [ORDER_STATUS]        NVARCHAR (20)   NULL,
    [ORDER_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [ORDER_REMARKS]       NVARCHAR (4000) NOT NULL,
    [PUBLIC_SERVICE_CODE] NVARCHAR (50)   NOT NULL,
    [CRE_DATE]            DATETIME        NOT NULL,
    [CRE_BY]              NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)   NOT NULL,
    [MOD_DATE]            DATETIME        NOT NULL,
    [MOD_BY]              NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)   NOT NULL
);

