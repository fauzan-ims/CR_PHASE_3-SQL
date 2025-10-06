CREATE TABLE [dbo].[OPL_INTERFACE_FINAL_GRN_REQUEST_DETAIL] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [FINAL_GRN_REQUEST_NO] NVARCHAR (50)   NULL,
    [ASSET_NO]             NVARCHAR (50)   NULL,
    [DELIVERY_TO]          NVARCHAR (4000) NULL,
    [BBN_NAME]             NVARCHAR (250)  NULL,
    [BBN_LOCATION]         NVARCHAR (4000) NULL,
    [BBN_ADDRESS]          NVARCHAR (4000) NULL,
    [YEAR]                 NVARCHAR (50)   NULL,
    [COLOUR]               NVARCHAR (50)   NULL,
    [CRE_DATE]             DATETIME        NOT NULL,
    [CRE_BY]               NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    [MOD_DATE]             DATETIME        NOT NULL,
    [MOD_BY]               NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]       NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_OPL_INTERFACE_FINAL_GRN_REQUEST_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);

