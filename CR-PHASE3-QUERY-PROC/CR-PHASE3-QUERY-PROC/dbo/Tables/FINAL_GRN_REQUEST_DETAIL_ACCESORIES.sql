CREATE TABLE [dbo].[FINAL_GRN_REQUEST_DETAIL_ACCESORIES] (
    [ID]                                     BIGINT        IDENTITY (1, 1) NOT NULL,
    [FINAL_GRN_REQUEST_DETAIL_ID]            BIGINT        NULL,
    [FINAL_GRN_REQUEST_DETAIL_ACCESORIES_ID] BIGINT        NULL,
    [APPLICATION_NO]                         NVARCHAR (50) NULL,
    [CRE_DATE]                               DATETIME      NOT NULL,
    [CRE_BY]                                 NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]                         NVARCHAR (15) NOT NULL,
    [MOD_DATE]                               DATETIME      NOT NULL,
    [MOD_BY]                                 NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]                         NVARCHAR (15) NOT NULL,
    [id_temp]                                INT           NULL,
    [GRN_PO_DETAIL_ID]                       BIGINT        NULL,
    CONSTRAINT [PK_FINAL_GRN_REQUEST_DETAIL_ACCESORIES] PRIMARY KEY CLUSTERED ([ID] ASC)
);

