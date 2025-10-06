CREATE TABLE [dbo].[TERMINATION_REQUEST] (
    [CODE]              NVARCHAR (50)  NOT NULL,
    [BRANCH_CODE]       NVARCHAR (50)  NOT NULL,
    [BRANCH_NAME]       NVARCHAR (250) NOT NULL,
    [POLICY_CODE]       NVARCHAR (50)  NOT NULL,
    [REQUEST_STATUS]    NVARCHAR (10)  NOT NULL,
    [REQUEST_DATE]      DATETIME       NOT NULL,
    [REQUEST_REFF_NO]   NVARCHAR (50)  NOT NULL,
    [REQUEST_REFF_NAME] NVARCHAR (250) NOT NULL,
    [TERMINATION_CODE]  NVARCHAR (50)  NULL,
    [CRE_DATE]          DATETIME       NOT NULL,
    [CRE_BY]            NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    [MOD_DATE]          DATETIME       NOT NULL,
    [MOD_BY]            NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_INSURANCE_TERMINATE_REQUEST] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_TERMINATION_REQUEST_INSURANCE_POLICY_MAIN] FOREIGN KEY ([POLICY_CODE]) REFERENCES [dbo].[INSURANCE_POLICY_MAIN] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada proses request terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_REQUEST', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang pada proses request terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang pada proses request terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_REQUEST', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode polis asuransi yang direquest untuk diterminate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_REQUEST', @level2type = N'COLUMN', @level2name = N'POLICY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada proses request terminate asuransi tersebut - HOLD, menginformasikan bahwa data request terminate asuransi tersebut belum diproses - POST, menginformasikan bahwa data request terminate asuransi tersebut telah diposting - CANCEL, menginformasikan bahwa data request terminate asuransi tersebut telah dibatalkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukan proses request terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor referensi pada proses request terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_REFF_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama referensi request pada proses request terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_REQUEST', @level2type = N'COLUMN', @level2name = N'REQUEST_REFF_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode termination pada proses request terminate asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TERMINATION_REQUEST', @level2type = N'COLUMN', @level2name = N'TERMINATION_CODE';

