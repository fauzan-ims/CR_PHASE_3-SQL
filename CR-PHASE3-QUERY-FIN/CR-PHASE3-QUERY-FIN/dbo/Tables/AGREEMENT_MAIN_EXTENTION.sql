CREATE TABLE [dbo].[AGREEMENT_MAIN_EXTENTION] (
    [AGREEMENT_NO]   NVARCHAR (50) NOT NULL,
    [REFF_1]         NVARCHAR (50) NULL,
    [REFF_2]         NVARCHAR (50) NULL,
    [REFF_3]         NVARCHAR (50) NULL,
    [REFF_4]         NVARCHAR (50) NULL,
    [REFF_5]         NVARCHAR (50) NULL,
    [REFF_6]         NVARCHAR (50) NULL,
    [REFF_7]         NVARCHAR (50) NULL,
    [REFF_8]         NVARCHAR (50) NULL,
    [REFF_9]         NVARCHAR (50) NULL,
    [REFF_10]        NVARCHAR (50) NULL,
    [CRE_DATE]       DATETIME      NOT NULL,
    [CRE_BY]         NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]       DATETIME      NOT NULL,
    [MOD_BY]         NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_AGREEMENT_MAIN_EXTENTION] PRIMARY KEY CLUSTERED ([AGREEMENT_NO] ASC),
    CONSTRAINT [FK_AGREEMENT_MAIN_EXTENTION_AGREEMENT_MAIN] FOREIGN KEY ([AGREEMENT_NO]) REFERENCES [dbo].[AGREEMENT_MAIN] ([AGREEMENT_NO])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor kontrak pembiayaan pada data extention kontrak pembiayaan tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AGREEMENT_MAIN_EXTENTION', @level2type = N'COLUMN', @level2name = N'AGREEMENT_NO';

