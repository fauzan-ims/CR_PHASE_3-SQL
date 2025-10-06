CREATE TABLE [dbo].[APPLICATION_CHARGES] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [APPLICATION_NO]         NVARCHAR (50)   NOT NULL,
    [CHARGES_CODE]           NVARCHAR (50)   NOT NULL,
    [DAFAULT_CHARGES_RATE]   DECIMAL (9, 6)  CONSTRAINT [DF_APPLICATION_CHARGES_CHARGES_RATE] DEFAULT ((0)) NOT NULL,
    [DAFAULT_CHARGES_AMOUNT] DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_CHARGES_CHARGES_AMOUNT1] DEFAULT ((0)) NOT NULL,
    [CALCULATE_BY]           NVARCHAR (10)   NOT NULL,
    [CHARGES_RATE]           DECIMAL (9, 6)  CONSTRAINT [DF_APPLICATION_CHARGES_DAFAULT_CHARGES_RATE1] DEFAULT ((0)) NOT NULL,
    [CHARGES_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_APPLICATION_CHARGES_CHARGES_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [IS_FROM_APPLICATION]    NVARCHAR (1)    NULL,
    [NEW_CALCULATE_BY]       NVARCHAR (10)   NULL,
    [NEW_CHARGES_RATE]       DECIMAL (9, 6)  NULL,
    [NEW_CHARGES_AMOUNT]     DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_APPLICATION_CHARGES] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_APPLICATION_CHARGES_APPLICATION_MAIN] FOREIGN KEY ([APPLICATION_NO]) REFERENCES [dbo].[APPLICATION_MAIN] ([APPLICATION_NO]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_APPLICATION_CHARGES_MASTER_CHARGES] FOREIGN KEY ([CHARGES_CODE]) REFERENCES [dbo].[MASTER_CHARGES] ([CODE]) ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto Generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_CHARGES', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor aplikasi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_CHARGES', @level2type = N'COLUMN', @level2name = N'APPLICATION_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'kode biaya charge', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_CHARGES', @level2type = N'COLUMN', @level2name = N'CHARGES_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai persentase default atsa biaya charge tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_CHARGES', @level2type = N'COLUMN', @level2name = N'DAFAULT_CHARGES_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai default atas biaya charge tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_CHARGES', @level2type = N'COLUMN', @level2name = N'DAFAULT_CHARGES_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai persentase biaya charge', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_CHARGES', @level2type = N'COLUMN', @level2name = N'CHARGES_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai biaya charge', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APPLICATION_CHARGES', @level2type = N'COLUMN', @level2name = N'CHARGES_AMOUNT';

