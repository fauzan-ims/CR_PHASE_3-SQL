CREATE TABLE [dbo].[XXX_ORDER_DETAIL_07112023] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [ORDER_CODE]           NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [REGISTER_CODE]        NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [DP_TO_PUBLIC_SERVICE] DECIMAL (18, 2) NULL,
    [IS_REIMBURSE]         NVARCHAR (1)    NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL
);

