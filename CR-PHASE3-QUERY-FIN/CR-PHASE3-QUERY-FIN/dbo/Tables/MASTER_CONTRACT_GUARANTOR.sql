CREATE TABLE [dbo].[MASTER_CONTRACT_GUARANTOR] (
    [ID]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [MAIN_CONTRACT_NO]      NVARCHAR (50)   NULL,
    [GUARANTOR_CLIENT_TYPE] NVARCHAR (10)   NOT NULL,
    [GUARANTOR_CLIENT_CODE] NVARCHAR (50)   NULL,
    [RELATIONSHIP]          NVARCHAR (250)  NOT NULL,
    [GUARANTED_PCT]         DECIMAL (9, 6)  NOT NULL,
    [REMARKS]               NVARCHAR (4000) NOT NULL,
    [FULL_NAME]             NVARCHAR (250)  NULL,
    [GENDER_CODE]           NVARCHAR (50)   NULL,
    [MOTHER_MAIDEN_NAME]    NVARCHAR (250)  NULL,
    [PLACE_OF_BIRTH]        NVARCHAR (250)  NULL,
    [DATE_OF_BIRTH]         DATETIME        NULL,
    [PROVINCE_CODE]         NVARCHAR (50)   NULL,
    [PROVINCE_NAME]         NVARCHAR (250)  NULL,
    [CITY_CODE]             NVARCHAR (50)   NULL,
    [CITY_NAME]             NVARCHAR (250)  NULL,
    [ZIP_CODE_CODE]         NVARCHAR (50)   NULL,
    [ZIP_CODE]              NVARCHAR (50)   NULL,
    [ZIP_NAME]              NVARCHAR (250)  NULL,
    [SUB_DISTRICT]          NVARCHAR (250)  NULL,
    [VILLAGE]               NVARCHAR (250)  NULL,
    [ADDRESS]               NVARCHAR (4000) NULL,
    [RT]                    NVARCHAR (5)    NULL,
    [RW]                    NVARCHAR (5)    NULL,
    [AREA_MOBILE_NO]        NVARCHAR (4)    NULL,
    [MOBILE_NO]             NVARCHAR (15)   NULL,
    [ID_NO]                 NVARCHAR (50)   NULL,
    [NPWP_NO]               NVARCHAR (50)   NULL,
    [CRE_DATE]              DATETIME        NOT NULL,
    [CRE_BY]                NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    [MOD_DATE]              DATETIME        NOT NULL,
    [MOD_BY]                NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_MASTER_CONTRACT_GUARANTOR] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PERSONAL, CORPORATE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CONTRACT_GUARANTOR', @level2type = N'COLUMN', @level2name = N'GUARANTOR_CLIENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : GNDR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CONTRACT_GUARANTOR', @level2type = N'COLUMN', @level2name = N'GENDER_CODE';

