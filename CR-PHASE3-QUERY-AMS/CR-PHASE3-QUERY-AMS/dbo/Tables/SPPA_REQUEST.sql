CREATE TABLE [dbo].[SPPA_REQUEST] (
    [CODE]            NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [REGISTER_CODE]   NVARCHAR (50) NOT NULL,
    [REGISTER_DATE]   DATETIME      NOT NULL,
    [REGISTER_STATUS] NVARCHAR (10) NOT NULL,
    [SPPA_CODE]       NVARCHAR (50) NULL,
    [CRE_DATE]        DATETIME      NOT NULL,
    [CRE_BY]          NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]  NVARCHAR (15) NOT NULL,
    [MOD_DATE]        DATETIME      NOT NULL,
    [MOD_BY]          NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]  NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_INSURANCE_REQUEST_1] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_SPPA_REQUEST_INSURANCE_REGISTER] FOREIGN KEY ([REGISTER_CODE]) REFERENCES [dbo].[INSURANCE_REGISTER] ([CODE])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses SPPA request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_REQUEST', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode register pada proses SPPA request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_REQUEST', @level2type = N'COLUMN', @level2name = N'REGISTER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal register pada proses SPPA request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_REQUEST', @level2type = N'COLUMN', @level2name = N'REGISTER_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses SPPA request tersebut - HOLD, menginformasikan bahwa data SPPA request tersebut belum diproses - POST, menginformasikan bahwa data SPPA request tersebut sudah dilakukan proses posting', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_REQUEST', @level2type = N'COLUMN', @level2name = N'REGISTER_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode SPPA pada proses SPPA request tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPPA_REQUEST', @level2type = N'COLUMN', @level2name = N'SPPA_CODE';

