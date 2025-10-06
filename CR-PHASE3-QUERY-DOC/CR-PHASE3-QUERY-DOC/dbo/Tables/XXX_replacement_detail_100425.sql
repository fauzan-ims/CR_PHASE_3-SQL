CREATE TABLE [dbo].[XXX_replacement_detail_100425] (
    [ID]                            BIGINT          IDENTITY (1, 1) NOT NULL,
    [REPLACEMENT_CODE]              NVARCHAR (50)   NOT NULL,
    [REPLACEMENT_REQUEST_DETAIL_ID] BIGINT          NOT NULL,
    [ASSET_NO]                      NVARCHAR (50)   NOT NULL,
    [TYPE]                          NVARCHAR (10)   NULL,
    [BPKB_NO]                       NVARCHAR (50)   NULL,
    [BPKB_DATE]                     DATETIME        NULL,
    [BPKB_NAME]                     NVARCHAR (250)  NULL,
    [BPKB_ADDRESS]                  NVARCHAR (4000) NULL,
    [STNK_NAME]                     NVARCHAR (250)  NULL,
    [STNK_EXP_DATE]                 DATETIME        NULL,
    [STNK_TAX_DATE]                 DATETIME        NULL,
    [FILE_NAME]                     NVARCHAR (250)  NULL,
    [PATHS]                         NVARCHAR (250)  NULL,
    [CRE_DATE]                      DATETIME        NOT NULL,
    [CRE_BY]                        NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                      DATETIME        NOT NULL,
    [MOD_BY]                        NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                NVARCHAR (15)   NOT NULL
);

