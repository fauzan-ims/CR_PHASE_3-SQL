CREATE TABLE [dbo].[CLIENT_RELATION] (
    [ID]                             BIGINT          IDENTITY (1, 1) NOT NULL,
    [CLIENT_CODE]                    NVARCHAR (50)   NOT NULL,
    [RELATION_CLIENT_CODE]           NVARCHAR (50)   NULL,
    [RELATION_TYPE]                  NVARCHAR (15)   NOT NULL,
    [CLIENT_TYPE]                    NVARCHAR (10)   NOT NULL,
    [FULL_NAME]                      NVARCHAR (250)  NOT NULL,
    [GENDER_CODE]                    NVARCHAR (50)   NULL,
    [MOTHER_MAIDEN_NAME]             NVARCHAR (250)  NULL,
    [PLACE_OF_BIRTH]                 NVARCHAR (250)  NULL,
    [DATE_OF_BIRTH]                  DATETIME        NULL,
    [PROVINCE_CODE]                  NVARCHAR (50)   NULL,
    [PROVINCE_NAME]                  NVARCHAR (250)  NULL,
    [CITY_CODE]                      NVARCHAR (50)   NULL,
    [CITY_NAME]                      NVARCHAR (250)  NULL,
    [ZIP_CODE]                       NVARCHAR (50)   NULL,
    [ZIP_NAME]                       NVARCHAR (250)  NULL,
    [SUB_DISTRICT]                   NVARCHAR (250)  NULL,
    [VILLAGE]                        NVARCHAR (250)  NULL,
    [ADDRESS]                        NVARCHAR (4000) NULL,
    [RT]                             NVARCHAR (5)    NULL,
    [RW]                             NVARCHAR (5)    NULL,
    [AREA_MOBILE_NO]                 NVARCHAR (4)    NULL,
    [MOBILE_NO]                      NVARCHAR (15)   NULL,
    [ID_NO]                          NVARCHAR (50)   NULL,
    [NPWP_NO]                        NVARCHAR (50)   NULL,
    [SHAREHOLDER_TYPE]               NVARCHAR (15)   NULL,
    [SHAREHOLDER_PCT]                DECIMAL (9, 6)  NULL,
    [IS_OFFICER]                     NVARCHAR (1)    CONSTRAINT [DF_CLIENT_RELATION_IS_OFFICER] DEFAULT ((0)) NULL,
    [OFFICER_SIGNER_TYPE]            NVARCHAR (10)   CONSTRAINT [DF_CLIENT_RELATION_OFFICER_SIGNER_TYPE] DEFAULT ((0)) NULL,
    [OFFICER_POSITION_TYPE_CODE]     NVARCHAR (50)   NULL,
    [OFFICER_POSITION_TYPE_OJK_CODE] NVARCHAR (50)   NULL,
    [OFFICER_POSITION_TYPE_NAME]     NVARCHAR (250)  NULL,
    [ORDER_KEY]                      INT             CONSTRAINT [DF_CLIENT_RELATION_ORDER_KEY] DEFAULT ((0)) NULL,
    [IS_EMERGENCY_CONTACT]           NVARCHAR (1)    CONSTRAINT [DF_CLIENT_RELATION_IS_OFFICER1] DEFAULT ((0)) NULL,
    [FAMILY_TYPE_CODE]               NVARCHAR (50)   CONSTRAINT [DF_CLIENT_RELATION_IS_EMERGENCY_CONTACT1] DEFAULT ((0)) NULL,
    [REFERENCE_TYPE_CODE]            NVARCHAR (50)   CONSTRAINT [DF_CLIENT_RELATION_FAMILY_TYPE_CODE1] DEFAULT ((0)) NULL,
    [DATI_II_CODE]                   NVARCHAR (50)   NULL,
    [DATI_II_OJK_CODE]               NVARCHAR (50)   NULL,
    [DATI_II_NAME]                   NVARCHAR (250)  NULL,
    [IS_LATEST]                      NVARCHAR (1)    CONSTRAINT [DF_CLIENT_RELATION_IS_LATEST] DEFAULT ('') NULL,
    [COUNTER]                        INT             CONSTRAINT [DF_CLIENT_RELATION_COUNTER] DEFAULT ((0)) NULL,
    [CRE_DATE]                       DATETIME        NOT NULL,
    [CRE_BY]                         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                       DATETIME        NOT NULL,
    [MOD_BY]                         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]                 NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_CLIENT_RELATION] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_CLIENT_RELATION_CLIENT_MAIN] FOREIGN KEY ([CLIENT_CODE]) REFERENCES [dbo].[CLIENT_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FAMILY, OFFICER, SHAREHOLDER', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_RELATION', @level2type = N'COLUMN', @level2name = N'RELATION_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PERSONAL, CORPORATE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_RELATION', @level2type = N'COLUMN', @level2name = N'CLIENT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : GNDR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_RELATION', @level2type = N'COLUMN', @level2name = N'GENDER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SIGNER, APPROVER, NONE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_RELATION', @level2type = N'COLUMN', @level2name = N'OFFICER_SIGNER_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : CCOPO', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_RELATION', @level2type = N'COLUMN', @level2name = N'OFFICER_POSITION_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : CCOPO', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_RELATION', @level2type = N'COLUMN', @level2name = N'OFFICER_POSITION_TYPE_OJK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GC : CCOPO', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIENT_RELATION', @level2type = N'COLUMN', @level2name = N'OFFICER_POSITION_TYPE_NAME';

